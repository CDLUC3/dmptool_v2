
# class Api::V1::BaseController < ActionController::Metal
#   include ActionController::Rendering        # enables rendering
#   include ActionController::MimeResponds     # enables serving different content types like :xml or :json
#   include AbstractController::Callbacks      # callbacks for your authentication logic
#   include ActionController::Renderers::All
 
#   append_view_path "#{Rails.root}/app/views/api/v1" # you have to specify your views location as well: THIS DOESN"T WORK
# end




class Api::V1::BaseController < ActionController::Base
	respond_to :json





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





	
end

