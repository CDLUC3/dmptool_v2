class Api::V1::UsersController < Api::V1::BaseController
	before_action :authenticate

	def index 
    if user_role_in?(:dmp_admin)
      @users = User.all
      render json: @users, status: 200
    else
      render json: 'You are not authorized to look at this content', status: 401
    end
	end 


	def show
    if user_role_in?(:dmp_admin)
      @user = User.find(params[:id])
      render json: @user, status: 200
    else
      render json: 'You are not authorized to look at this content', status: 401
    end
  end


 

  # def authenticate
  #   authenticate_or_request_with_http_basic do |username, password|
  #     if Ldap_User.valid_ldap_credentials?(username, password)
  #       user = User.find_by_login_id(username)
  #       session[:user_id] = user.id
  #       session[:login_method] = "ldap"
  #     end
  #   end
  # end


end