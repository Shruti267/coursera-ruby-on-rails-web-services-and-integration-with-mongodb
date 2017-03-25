class Photo
  include Mongoid::Document

  attr_accessor :id, :location, :place
  attr_writer :contents

  def self.mongo_client
  	db = Mongo::Client.new('mongodb://localhost:27017')
  end

  def initialize(hash={})
  	@id = hash[:_id].to_s if !hash[:_id].nil?
  	if !hash[:metadata].nil?
  		@location = Point.new(hash[:metadata][:location]) if !hash[:metadata][:location].nil?
  		@place = hash[:metadata][:place]
  	end
  end

  def persisted?
  	!@id.nil?
  end

  def save
    if !persisted?
      gps = EXIFR::JPEG.new(@contents).gps

      description = {}
      description[:content_type] = 'image/jpeg'
      description[:metadata] = {}

      @location = Point.new(:lng => gps.longitude, :lat => gps.latitude)
      description[:metadata][:location] = @location.to_hash
      description[:metadata][:place] = @place

      if @contents
        @contents.rewind
        grid_file = Mongo::Grid::File.new(@contents.read, description)
        id = self.class.mongo_client.database.fs.insert_one(grid_file)
        @id = id.to_s
      end
    else
      self.class.mongo_client.database.fs.find(:_id => BSON::ObjectId(@id))
        .update_one(:$set => {
          :metadata => {
            :location => @location.to_hash,
            :place => @place
          }
        })
    end
  end

  def self.all(skip = 0, limit = nil)
  	docs = mongo_client.database.fs.find({}).skip(skip)
  	docs = docs.limit(limit) if !limit.nil?
  	docs.map do |doc|
  		Photo.new(doc)
  	end
  end

  def self.find(id)
  	doc = mongo_client.database.fs.find(:_id => BSON::ObjectId(id)).first
  	if doc.nil?
  		return nil
  	else
  		return Photo.new(doc)
  	end
  end

  def contents
  	doc = self.class.mongo_client.database.fs.find_one(:_id => BSON::ObjectId(@id))
  	if doc
  	  buffer = ""
  	  doc.chunks.reduce([]) do |x, chunk|
  	    buffer << chunk.data.data
  	  end
  	  return buffer
  	end
  end

  def destroy
  	self.class.mongo_client.database.fs.find(:_id => BSON::ObjectId(@id)).delete_one
  end

  def find_nearest_place_id(max_dist)
  	place = Place.near(@location, max_dist).limit(1).projection(:_id => 1).first
  	if place.nil?
  		return nil
  	else
  		return place[:_id]
  	end
  end

  def place
    if !@place.nil?
    	Place.find(@place.to_s)
    end
  end

  def place=(new_place)
    if new_place.is_a?(Place)
    	@place = BSON::ObjectId.from_string(new_place.id)
    elsif new_place.is_a?(String)
    	@place = BSON::ObjectId.from_string(new_place)
    else
    	@place = new_place
    end
  end

  def self.find_photos_for_place(place_id)
    if place_id.is_a?(BSON::ObjectId)
      new_id = place_id
    elsif place_id.is_a?(String)
      new_id = BSON::ObjectId.from_string(place_id.to_s)
    end
  	mongo_client.database.fs.find(:'metadata.place' => new_id)
  end
end
