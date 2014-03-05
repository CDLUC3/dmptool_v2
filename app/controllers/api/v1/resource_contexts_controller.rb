class Api::V1::ResourceContextsController < Api::V1::BaseController

	respond_to :json

  	def index         
    	@resource_contexts = ResourceContext.all     
  	end 

	def show
    	@resource_context = ResourceContext.find(params[:id])
  	end


end