class RacerInfo
  include Mongoid::Document
  field :fn,  as: :first_name, type: String
  validates :first_name, :presence => true
  field :ln, as: :last_name, type: String
  validates :last_name, :presence => true
  field :g, type: String, as: :gender
  validates :gender, :presence => true, :inclusion => { :in => %w(F M) }
  field :yr, type: Integer, as: :birth_year
  validates :birth_year, :presence => true, :numericality => { :less_than => Time.now.year }
  field :res, type: Address, as: :residence
  
  field :racer_id, as: :_id
  field :_id, default:->{ racer_id }

  embedded_in :parent, polymorphic: true

=begin
  def city
    self.residence ? self.residence.city : nil
  end
  def city= name
    object=self.residence ||= Address.new
    object.city=name
    self.residence=object
  end

##### REPLACED by the metaprogrammed def underneath

=end    

  ["city", "state"].each do |action|
      define_method("#{action}") do
          self.residence ? self.residence.send("#{action}") : nil
      end
      define_method("#{action}=") do |name|
          object=self.residence ||= Address.new({"#{action}" => name})
          object.send("#{action}=", name)
          self.residence=object
      end 
  end #city-state metaprog def

end
