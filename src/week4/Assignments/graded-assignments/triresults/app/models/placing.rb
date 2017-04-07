class Placing 
# format {:name=>"(category name)" :place=>"(ordinal placing)"}

attr_accessor :name, :place

  def initialize(hash)
    @name = hash[:name]
    @place = hash[:place]
  end

  def mongoize
    {:name=>@name, :place=>@place}
  end


  def self.demongoize(object)
  
    case object
	    when nil then nil
	    when Placing then object
		when Hash then Placing.new(object)
	end #case
  
  end #def


  def self.mongoize(object) 
    
    case object
	    when nil then nil
	    when Placing then object.mongoize
		when Hash then Placing.new(object).mongoize
	end #case
  
  end #def
   
  def self.evolve(object)

    case object
    	when Placing then object.mongoize
    	else object
    end #case
  
  end #def

end #class end