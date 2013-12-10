class UserSessionsController < ApplicationController
  
   def my_logger
    @@my_logger ||= Logger.new("#{Rails.root}/log/shib_debug.log")
  end

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
    redirect_to choose_institution_path if session[:institution_id].blank?
    my_logger.info ""
    env.each do |k,v|
      if k.starts_with?('omni')
        my_logger.debug "#{k}=#{v}"
      end
    end
    
    return
    
    user = User.from_omniauth(env["omniauth.auth"], session['institution_id'])
    session[:user_id] = user.id
    redirect_to dashboard_path #otherwise if old user with institution set, send to dashboard
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
