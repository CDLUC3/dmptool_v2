class UserSessionsController < ApplicationController

  def login
    if !params[:institution_id].blank?
      session['institution_id'] = params[:institution_id]
    elsif session['institution_id'].blank?
      redirect_to choose_institution_path, flash: {error: 'Please choose your log in institution.'} and return
    end
    @institution = Institution.find(session[:institution_id])
    if !@institution.shib_domain.blank?
      #initiate shibboleth login sequence
      redirect_to OmniAuth::Strategies::Shibboleth.login_path_with_entity(
          Dmptool2::Application.shibboleth_host, @institution.shib_entity_id)
    else
      #just let the original form render
    end
  end

  def create
    redirect_to choose_institution_path if session[:institution_id].blank? and return
    user = User.from_omniauth(env["omniauth.auth"], session['institution_id'])
    redirect_to login_path, flash: { error: 'Invalid Username/Password' } and return if !user.active?
    session[:user_id] = user.id
    if user.first_name.blank? || user.last_name.blank? || user.prefs.blank?
      redirect_to edit_user_path(user), flash: {error: 'Please complete your user information.'} and return
    else
      redirect_to dashboard_path and return
    end
  end

  def failure
    redirect_to login_path, flash: { error: 'Invalid Username/Password' }
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out."
  end

  #allow choosing the institution before logging in.
  def institution
     @inst_list = InstitutionsController.institution_select_list
  end

end
