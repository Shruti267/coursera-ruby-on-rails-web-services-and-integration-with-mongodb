class Event

  include Mongoid::Document
  
  field :o, type: Integer, as: :order
  field :n, type: String, as: :name
  field :d, type: Float, as: :distance
  field :u, type: String, as: :units

  validates :order, presence: true
  validates :name, presence: true

  embedded_in :parent, polymorphic: true, touch: true
  



def meters
	case units
			when "meters" then distance
			when "kilometers" then distance*1000
			when "yards" then distance*0.9144
			when "miles" then distance*1609.34
			else nil
	end if distance?

end

def miles
		case units
			when "meters" then distance*0.000621371
			when "kilometers" then distance*0.621371
			when "yards" then distance*0.000568182
			when "miles" then distance
			else nil
		end if distance?

end

end #class

=begin
1 meter = 0.000621371 miles
• 1 kilometer = 0.621371 miles
• 1 yard = 0.000568182 miles
• 1 yard = 0.9144 meters
• 1 mile = 1609.34 meters
=end
