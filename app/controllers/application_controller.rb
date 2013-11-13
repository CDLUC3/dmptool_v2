class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # enable_authorization

  helper_method :current_user

  

  protected

    def current_user
      @current_user ||= User.find_by_login_id(session[:login_id]) if session[:login_id]
    end

    def check_admin_access
      unless (current_user.has_role?(1) || current_user.has_role?(2) || current_user.has_role?(3) || current_user.has_role?(4) || current_user.has_role?(5))    
        flash[:error] = "You don't have access to this content"
        redirect_to root_url # halts request cycle
      end
    end

    def check_institution_admin
      unless (current_user.has_role?(1) || current_user.has_role?(5) )    
        flash[:error] = "You don't have access to this content"
        redirect_to root_url # halts request cycle
      end
    end

end
