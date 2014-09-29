
class Api::V1::BaseController < ActionController::Base
	respond_to :json

  #API calls should be stateless. Otherwise Rails would check for an authenticity token on POST, PUT/PATCH and DELETE.
  protect_from_forgery with: :null_session


	

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

  def user_role_in?(*roles)
    if (roles - ROLES.keys).length > 0
      raise "role not defined in application_controller#user_role_in?.  It's likely you've mistyped a role symbol."
    end
    return false if current_user.nil?
    r = roles.map {|i| ROLES[i]}
    matching_roles = current_user.roles.pluck(:id) & r
    return true if matching_roles.length > 0
    return false
  end

  ROLES =
      {   :dmp_admin              => Role::DMP_ADMIN,
          :resource_editor        => Role::RESOURCE_EDITOR,
          :template_editor        => Role::TEMPLATE_EDITOR,
          :institutional_reviewer => Role::INSTITUTIONAL_REVIEWER,
          :institutional_admin    => Role::INSTITUTIONAL_ADMIN}




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


	
end

