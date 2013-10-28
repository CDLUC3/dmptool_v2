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
end
