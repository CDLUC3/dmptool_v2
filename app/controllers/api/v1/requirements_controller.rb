class Api::V1::RequirementsController < Api::V1::BaseController

	respond_to :json

  	def index         
    	@requirements = Requirement.all     
  	end 

	def show
    	@requirement = Requirement.find(params[:id])
  	end


end