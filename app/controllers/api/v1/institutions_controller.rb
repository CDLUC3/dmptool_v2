class Api::V1::InstitutionsController < Api::V1::BaseController
	 
	include ApplicationHelper
	respond_to :json

  	def index         
    	@institutions = Institution.all 
  	end 

	def show
    	@institution = Institution.find(params[:id])
    	#@plans_count = plans_count_for_institution(@institution)
  	end

  	

end