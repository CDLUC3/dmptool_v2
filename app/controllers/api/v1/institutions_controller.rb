class Api::V1::InstitutionsController < Api::V1::BaseController
  #before_action :require_admin
	 
	respond_to :json

	def index         
  	@institutions = Institution.all 
	end 

	def show
    	@institution = Institution.find(params[:id])
  end  

	def plans_count_show
  	@institution = Institution.find(params[:id])
	end 

	def plans_count_index
  	@institutions = Institution.all 
	end 

	def admins_count_show
  	@institution = Institution.find(params[:id])
	end 

	def admins_count_index
  	@institutions = Institution.all 
	end	

  

end