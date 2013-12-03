class UserSessionsController < ApplicationController

  def login
    if !params[:institution_id].blank?
      session['institution_id'] = params[:institution_id]
    elsif params[:instituion_id].blank? && session['institution_id'].blank?
      redirect_to choose_institution_path, flash: {error: 'Please choose your institution to log in.'}
    end
    @institution = Institution.find(session[:institution_id])
  end

  def create
    redirect_to choose_institution_path if session[:institution_id].blank?
    user = User.from_omniauth(env["omniauth.auth"], session['institution_id'])
    session[:login_id] = user.login_id
    redirect_to dashboard_path #otherwise if old user with institution set, send to dashboard
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
