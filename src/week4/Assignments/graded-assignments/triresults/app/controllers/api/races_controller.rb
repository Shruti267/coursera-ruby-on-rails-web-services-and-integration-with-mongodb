module Api
	

	class RacesController < BaseController

#		before_action :set_race, only: [:put, :destroy]
  		
		rescue_from Mongoid::Errors::DocumentNotFound do |exception|
        	render	:status=>:not_found,
					:template=>"api/error_msg",
					:locals=>{ :msg=>"woops: cannot find race[#{@id}]"}
    	end

    	rescue_from ActionView::MissingTemplate do |exception|
			Rails.logger.debug exception
			render 	plain: "woops: we do not support that content-type[#{request.accept}]",
					:status => 415
		end

  		def index
			answer = "/api/races"
  			limit||=params["limit"]
  			offset||=params["offset"]
  			answer+= ", offset=[#{offset}]" if offset
  			answer+= ", limit=[#{limit}]" if limit

  			if !request.accept || request.accept == "*/*"
        		render plain: answer
      		else
        		render plain: "real implementation ..."
      		end
  		end

  		def create
  			
  			if !request.accept || request.accept == "*/*"

 				answer=(params["race"]["name"] if params["race"])||""
        		render plain: answer, status: :ok
      		elsif !request.accept || request.accept != "*/*"
      			race = Race.create(race_params)
      			render plain: race.name, status: :created

      		else
        		render plain: ""
      		end
  		end

  		def show
  			if !request.accept || request.accept == "*/*"
        		render plain: "/api/races/#{params[:id]}"


#        	elsif !request.accept || request.accept == "application/xml" || request.accept == "application/json"
#        		render "show", status: :ok

       		else
        		#render status: :ok
#        		render json: @race
            set_race
    				render "show", status: :ok
      		end
  		end

  		def put
  			set_race
  			Rails.logger.debug("method=#{request.method}")
  			@race.update(race_params)
  			render json: @race  				
  		end
  		def destroy
  			set_race
  			@race.destroy
  			render :nothing=>true, :status => :no_content
  		end

  		def results
  			if !request.accept || request.accept == "*/*"
        		render plain: "/api/races/#{params[:race_id]}/results"
      		else
      			@id=params[:race_id]
        		@race=Race.find(@id)
				    if stale?(last_modified: @race.entrants.max(:updated_at))
                @entrants=@race.entrants
            end
				    #fresh_when(etag: @entrants, last_modified: @entrants.max(:updated_at), public: true)

      		end
  		end

  		def result
  			if !request.accept || request.accept == "*/*"
        		render plain: "/api/races/#{params[:race_id]}/results/#{params[:id]}"
      		else
        		@result=Race.find(params[:race_id]).entrants.where(:id=>params[:id]).first
        		render :partial=>"result", :object=>@result
      		end
  		end

  		def res_patch

  			set_entrant

  			if result_params
        		if result_params[:swim]
		        	@result.swim=@result.race.race.swim
		          	@result.swim_secs = result_params[:swim].to_f
		        end
		        if result_params[:t1]
		          	@result.t1=@result.race.race.t1
		          	@result.t1_secs = result_params[:t1].to_f
		        end
		        if result_params[:bike]
		          	@result.bike=@result.race.race.bike
		          	@result.bike_secs = result_params[:bike].to_f
		        end
		        if result_params[:t2]
		          	@result.t2=@result.race.race.t2
		          	@result.t2_secs = result_params[:t2].to_f
		        end
		        if result_params[:run]
		          	@result.run=@result.race.race.run
		          	@result.run_secs = result_params[:run].to_f
		        end        
        		@result.save
      		end
      		render json: @result, :status => :ok
  		end

  	private
  	
  		def race_params
  			params.require(:race).permit(:name, :date)
  		end

  		def set_race
  			@id = params[:id]
  			@race ||= Race.find(@id)

  		end
      	
      	def set_entrant
        	@race = Race.find(params[:race_id])
        	@result=@race.entrants.where(:id=>params[:id]).first
      	end
      	
      	def result_params
        	params.require(:result).permit(:swim, :t1, :bike, :t2, :run)
      	end
	end #RacesController
end #Api

=begin
module Api
	class Race < BaseController
		before_action :set_movie, only: [:show, :edit, :update, :destroy]

		    def index
		      respond_with Movie.all
		    end
		    def show
		      respond_with @movie
		    end
		    def create
		      respond_with Movie.create(movie_params)
		    end
		    def update
		      respond_with @movie.update(movie_params)
		    end
		    def destroy
		      respond_with @movie.destroy
		    end

		    private
		      def set_movie
		        @movie = Movie.find(params[:id])

		        rescue Mongoid::Errors::DocumentNotFound => e
		          respond_to do |format|
		            format.json { render json: {msg:"movie[#{params[:id]}] not found"}, status: :not_found }
		          end
		      end
		      def movie_params
		        params.require(:movie).permit(:id, :title)
		      end
		    #end private

	end #Race
end #Api

=end
