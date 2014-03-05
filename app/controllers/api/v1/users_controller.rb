class Api::V1::UsersController < Api::V1::BaseController

	respond_to :json

  	def index         
    	@users = User.all     
  	end 

	def show
    	@user = User.find(params[:id])
  	end


end