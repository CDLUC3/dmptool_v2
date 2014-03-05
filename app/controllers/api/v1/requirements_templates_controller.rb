class Api::V1::RequirementsTemplatesController < Api::V1::BaseController

	respond_to :json

  	def index         
    	@requirements_templates = RequirementsTemplate.all     
  	end 

	def show
    	@requirements_template = RequirementsTemplate.find(params[:id])
  	end


end