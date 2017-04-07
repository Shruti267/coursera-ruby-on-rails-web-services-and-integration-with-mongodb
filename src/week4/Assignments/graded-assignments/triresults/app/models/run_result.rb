class RunResult < LegResult

field :mmile, type: Float, as: :minute_mile

def calc_ave
	if event && secs
		miles = event.miles
		self.minute_mile= miles.nil? ? nil : (secs/60)/miles
	end
end

end