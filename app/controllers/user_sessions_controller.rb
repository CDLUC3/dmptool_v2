class UserSessionsController < ApplicationController

  def login

  end

  def create
    sign_in_or_create(auth_hash)

    if signed_in?
      redirect_to edit_user_path(current_user)
    else
      redirect_to login_path
    end
  end

  def failure
    redirect_to login_path, flash: { error: 'Invalid Username/Password' }
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  protected

    def auth_hash
      request.env['omniauth.auth']
    end
end
