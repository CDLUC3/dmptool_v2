class Api::V1::RolesController < Api::V1::BaseController

	respond_to :json

  	def index         
    	@roles = Role.all     
  	end 

	def show
    	@role = Role.find(params[:id])
  	end


end