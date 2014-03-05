class Api::V1::ResponsesController < Api::V1::BaseController

	respond_to :json

  	def index         
    	@responses = Response.all     
  	end 

	def show
    	@response = Response.find(params[:id])
  	end


end