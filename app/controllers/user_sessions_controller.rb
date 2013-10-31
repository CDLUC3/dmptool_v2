class UserSessionsController < ApplicationController

  def login

  end

  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:login_id] = user.login_id
    if user.created_at.time.utc + 1 > Time.new.utc || user.institution_id.nil? || user.institution_id == 0
      redirect_to edit_user_path(current_user) #edit info or set institution
    else
      redirect_to dashboard_path #otherwise if old user with institution set, send to dashboard
    end
  end

  def failure
    redirect_to login_path, flash: { error: 'Invalid Username/Password' }
  end

  def destroy
    session[:login_id] = nil
    redirect_to root_path, notice: "Signed out."
  end
  
  #allow choosing the institution before logging in.
  def institution
     @inst_list = InstitutionsController.institution_select_list
  end

end
