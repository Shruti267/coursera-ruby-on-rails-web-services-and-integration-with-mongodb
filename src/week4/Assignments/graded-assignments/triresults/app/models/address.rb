class Address
#format {:city=>"(city)", :state=>"(state)", :loc=>(point)}
attr_accessor :city, :state, :location

def initialize hash={}
	@city = hash[:city]  || nil
	@state= hash[:state] || nil
	hash[:loc] ? (@location = Point.demongoize hash[:loc]) : nil
end
def mongoize
	{:city=>@city, :state=>@state, :loc=>@location.mongoize}
end

def self.mongoize(object)
	case object
		when nil then nil
		when Address then object.mongoize
		when Hash then self.new(object).mongoize
	end #case
end

def self.demongoize(object)
	case object
		when nil then nil
		when Address then object
		when Hash then self.new(object)
	end #case
end #self.demongoize

 def self.evolve(object)
    case object
    when Address then object.mongoize
    else object
    end
  end

end #class