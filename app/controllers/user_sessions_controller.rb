class UserSessionsController < ApplicationController

  def login

  end

  def create
    sign_in_or_create(auth_hash)

    redirect_to login_path
  end

  def failure
    redirect_to login_path, alert: 'Invalid Username/Password'
  end

  protected

    def auth_hash
      request.env['omniauth.auth']
    end
end
