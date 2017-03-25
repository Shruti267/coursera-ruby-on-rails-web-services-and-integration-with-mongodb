class Place
  include ActiveModel::Model

  attr_accessor :id, :formatted_address, :location, :address_components

  def initialize(params={})
      @id = params[:_id].to_s
      @formatted_address = params[:formatted_address]
      @location = Point.new(params[:geometry][:geolocation])
      @address_components = params[:address_components]
        .map{ |a| AddressComponent.new(a)} if !params[:address_components].nil?
  end

  def persisted?
    !@id.nil?
  end

  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    self.mongo_client['places']
  end

  def self.load_all(file)
  	docs = JSON.parse(file.read)
  	collection.insert_many(docs)
  end

  def self.find_by_short_name(short_name)
    collection.find(:'address_components.short_name' => short_name)
  end

  def self.to_places(places)
    places.map { |p| Place.new(p) }
  end

  def self.find(id)
    id = BSON::ObjectId.from_string(id)
    doc = collection.find(:_id => id).first
    return doc.nil? ? nil : Place.new(doc)
  end

  def self.all(offset = 0, limit = nil)
    docs = collection.find({})
      .skip(offset)
    docs = docs.limit(limit) if !limit.nil?
    docs = to_places(docs)
  end

  def destroy
    id = BSON::ObjectId.from_string(@id);
    self.class.collection.delete_one(:_id => id)
  end

  def self.get_address_components(sort = nil, offset = 0, limit = 0)
    pline = [
      { :$unwind => "$address_components" },
      {
        :$project => {
          :_id => 1,
          :address_components => 1,
          :formatted_address => 1,
          :'geometry.geolocation' => 1 }
      }
    ]
    pline.push({:$sort=>sort}) if !sort.nil?
    pline.push({:$skip=>offset}) if offset != 0
    pline.push({:$limit=>limit}) if limit != 0
    collection.find.aggregate(pline)
  end

  def self.get_country_names
    pline = [
      { :$unwind => '$address_components' },
      {
        :$project => {
          :'address_components.long_name' => 1,
          :'address_components.types' => 1
        }
      },
      { :$match => { :"address_components.types" => "country" } },
      { :$group => { :"_id" => '$address_components.long_name' } }
    ]
    docs = collection.find.aggregate(pline)

    docs.to_a.map {|h| h[:_id]}
  end

  def self.find_ids_by_country_code(country_code)
    pline = [
      { :$match => {
        :'address_components.types' => "country",
        :'address_components.short_name' => country_code
        }
      },
      { :$project => { :_id => 1 } }
    ]

    collection.find.aggregate(pline).to_a.map { |doc| doc[:_id].to_s }
  end

  def self.create_indexes
    collection.indexes.create_one(:'geometry.geolocation' => Mongo::Index::GEO2DSPHERE)
  end

  def self.remove_indexes
    collection.indexes.drop_one('geometry.geolocation_2dsphere')
  end

  def self.near(point, max_meters=nil)
    query = {
      :'geometry.geolocation' => {
        :$near => {
          :$geometry => point.to_hash,
          :$maxDistance => max_meters
        }
      }
    }
    collection.find(query)
  end

  def near(max_meters=nil)
    if (!@location.nil?)
      self.class.to_places(self.class.near(@location, max_meters))
    end
  end

  def photos(offset = 0, limit = nil)
    photos = Photo.find_photos_for_place(@id).skip(offset)
    photos = photos.limit(limit) if !limit.nil?
    if photos.count
      result = photos.map { |photo| Photo.new(photo) }
    else
      result = []
    end
    return result
  end
end
