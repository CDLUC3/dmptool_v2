class Api::V1::InstitutionsController < Api::V1::BaseController
	 
	respond_to :json


	def index         
  	@institutions = Institution.all 
	end 


	def show
    if @institution = Institution.find_by_id(params[:id]) 
      @institution 
    else
      render json: 'The institution you are looking for doesn\'t exist', status: 404
    end
  end  


	def plans_count_show
  	if @institution = Institution.find_by_id(params[:id]) 
      @institution 
    else
      render json: 'The institution you are looking for doesn\'t exist', status: 404
    end
	end 


	def plans_count_index
  	@institutions = Institution.all 
	end 


	def admins_count_show
  	if @institution = Institution.find_by_id(params[:id]) 
      @institution 
    else
      render json: 'The institution you are looking for doesn\'t exist', status: 404
    end
	end 


	def admins_count_index
  	@institutions = Institution.all 
	end	
 

end