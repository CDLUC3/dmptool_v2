class Api::V1::UsersController < Api::V1::BaseController
	before_action :require_admin

	respond_to :json

  	def index         
    	@users = User.all     
  	end 

	def show
    	@user = User.find(params[:id])
  	end


  def require_admin
    unless user_role_in?(:dmp_admin)
      flash[:error] = "You must be an administrator to access this page."
      session[:return_to] = request.original_url
      redirect_to choose_institution_path and return
    end
  end

  def safe_has_role?(role)
    #this returns whether a user has a role, but does it safely.  If no user is logged in
    #then it returns false by default.  Will work with either number or more readable role name.
    return false if current_user.nil?
    if role.class == Fixnum || (role.class == String && role.match(/^[-+]?[1-9]([0-9]*)?$/) )
      current_user.has_role?(role)
    else
      current_user.has_role_name?(role)
    end
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

end