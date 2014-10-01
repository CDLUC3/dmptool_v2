class Api::V1::UsersController < Api::V1::BaseController
	before_action :authenticate

	def index 
    if user_role_in?(:dmp_admin)
      @users = User.all
      render json: @users, status: 200
    elsif user_role_in?(:institutional_admin) 
      @users = User.all
      render json: @users, status: 200
    else
      render json: 'You are not authorized to look at this content', status: 401
    end
	end 


	def show
    if @user = User.find_by_id(params[:id])
      if user_role_in?(:dmp_admin)
        render json: @user, status: 200
      elsif user_role_in?(:institutional_admin)
        if current_user.institution.subtree_ids.include?(@user.institution.id)
          render json: @user, status: 200
        else
          render json: 'You are not authorized to look at this content', status: 401
        end
      else
        render json: 'You are not authorized to look at this content', status: 401
      end
    else
      render json: 'The user you are looking for doesn\'t exist', status: 404
    end
  end


 
#basic auth authentication
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