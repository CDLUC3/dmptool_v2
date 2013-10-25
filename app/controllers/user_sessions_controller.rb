class UserSessionsController < ApplicationController

  def login

  end

  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:login_id] = user.login_id
    redirect_to edit_user_path(current_user)
  end

  def failure
    redirect_to login_path, flash: { error: 'Invalid Username/Password' }
  end

  def destroy
    session[:login_id] = nil
    redirect_to root_path, notice: "Signed out."
  end

end
