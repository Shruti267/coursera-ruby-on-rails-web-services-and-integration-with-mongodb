module Api
	class RacersController < BaseController
		
		def index
			if !request.accept || request.accept == "*/*"
        		render plain: "/api/racers"
     		else
       			render plain: "real implementation ..."
      		end
		end

  		def create
  			if !request.accept || request.accept == "*/*"
        		render plain: :nothing, status: :ok
      		else
        		#real implementation
      		end
  		end

		def show
			if !request.accept || request.accept == "*/*"
        		render plain: "/api/racers/#{params[:id]}"
     		else
       			render plain: "real implementation ..."
      		end
		end

		def entries
			if !request.accept || request.accept == "*/*"
        		render plain: "/api/racers/#{params[:racer_id]}/entries"
     		else
       			render plain: "real implementation ..."
      		end
		end

		def entry
			if !request.accept || request.accept == "*/*"
        		render plain: "/api/racers/#{params[:racer_id]}/entries/#{params[:id]}"
     		else
       			render plain: "real implementation ..."
      		end
		end
			
	end #class RacersController
end #module Api
