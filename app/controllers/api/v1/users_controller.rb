class Api::V1::UsersController < Api::V1::BaseController
	before_action :authenticate

	# respond_to :json

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


  protected

  
  def authenticate
    authenticate_token || render_unauthorized
  end

  
  def authenticate_token
    authenticate_with_http_token do |token, options|
      user = User.find_by(auth_token: token)
      session[:user_id] = user.id if user
    end

  end


  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Users"'
    render json: 'Bad credentials', status: 401
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