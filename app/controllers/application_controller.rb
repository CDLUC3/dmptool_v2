class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # enable_authorization

  helper_method :current_user

  protected

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def login_user(user)
    @current_user = user
    session[:user_id] = user.id
  end

  def require_user
    unless current_user
      go_to_login
    end
  end


end
