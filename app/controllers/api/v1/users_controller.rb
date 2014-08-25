class Api::V1::UsersController < Api::V1::BaseController
	# before_action :require_admin

	http_basic_authenticate_with name: 'admin', password: 'secret'

	respond_to :json

  	def index         
    	@users = User.all     
  	end 

	def show
    @user = User.find(params[:id])
  end





end