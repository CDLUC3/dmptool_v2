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
    auth = env["omniauth.auth"]
    user = User.from_omniauth(auth, session['institution_id'])
    if auth[:provider] == 'shibboleth' && user.nil?
      redirect_to choose_institution_path, flash: { error: 'Problem with InCommon login.  Your InCommon provider may not be releasing the necessary attributes.'} and return
    end
    if user.nil? || !user.active?
     redirect_to choose_institution_path, flash: { error: "Incorrect username, password or institution" } and return
    end 
    session[:user_id] = user.id
    session[:login_method] = auth[:provider]

    if user.first_name.blank? || user.last_name.blank? || user.prefs.blank?
      redirect_to edit_user_path(user), flash: {error: 'Please complete filling in your profile information.'} and return
    else
      unless session[:return_to].blank?
        r = session[:return_to]
        session.delete(:return_to)
        redirect_to r and return
      end
      redirect_to dashboard_path and return
    end
  end

  def failure
    redirect_to choose_institution_path, flash: { error: "Failure: Incorrect username, password or institution" }
  end

  def destroy
    reset_session
    session[:user_id]
    redirect_to root_path, notice: "Signed out."
  end

  #allow choosing the institution before logging in.
  def institution
     @inst_list = InstitutionsController.institution_select_list
  end
  
  #email username from email address -- get the form, post the submission
  def username_reminder
    if request.post?
      email = params[:email]
      if email.present? && email.match(/^.+\@.+\..+$/)
        users =  User.where(email: email).includes(:authentications).where(active: true).where(authentications: {:provider => 'ldap'})
        if users.length > 0
          uid = users.first.authentications.first.uid
          UsersMailer.username_reminder(uid, email).deliver
          flash[:notice] = "Your username has been emailed to #{email}."
          redirect_to login_path
        else
          flash[:error] = "No user found with email address #{email}."
          redirect_to(:action => 'username_reminder', email: email) and return
        end
      else
        flash[:error] = "You must supply a valid email to obtain a username reminder."
        redirect_to(:action => 'username_reminder', email: email) and return
      end
    end
  end
  
  #reset the password for an email address and mail it -- get is the form, post the submission
  def password_reset
    if request.post?
      email = params[:email]
      if email.present?
        ldap_user = nil
        dmp_user = false
        if email.match(/^.+\@.+\..+$/)
          users =  User.where(email: email).where(active: true)
          begin
            ldap_user = Ldap_User.find_by_email(email)
            dmp_user = ldap_user.objectclass.include?('dmpUser')
          rescue Exception => ex
          end
        else
          users =  User.where(active: true).where(login_id: email)
          begin
            ldap_user = Ldap_User.find_by_id(email)
            dmp_user = ldap_user.objectclass.include?('dmpUser')
          rescue Exception => ex
          end
        end
        if users.length > 0 && !ldap_user.nil? && dmp_user
          user = users.first
          email = user.email
          token = user.ensure_token
          reset_url = complete_password_reset_url(:id => user.id, :token => token, :protocol => 'https')
          UsersMailer.password_reset(user.login_id, email, reset_url).deliver
          
          flash[:notice] = "An email has been sent to #{email} with instructions for resetting your password."
          redirect_to login_path and return
        elsif user.length < 1
          flash[:error] = "No user found with email or username #{email}."
          redirect_to(:action => 'password_reset', email: email) and return
        elsif ldap_user.nil?
          flash[:error] = "You must reset your Shibboleth password through your own institution's password reset mechanism." +
                          "  You do not have an independent login for the DMPTool."
          redirect_to(:action => 'password_reset', email: email) and return
        elsif dmp_user == false
          flash[:error] = "Your LDAP account has not been enabled for use in the DMPTool.  Your account must be set up in the DMPTool before you can change your password."
          redirect_to(:action => 'password_reset', email: email) and return
        end
      else
        flash[:error] = "You must supply an email or username to request a password reset."
        redirect_to(:action => 'password_reset', email: email) and return
      end
    end
  end
  
  def complete_password_reset
    user_id = params[:id]
    token = params[:token]
    @user = User.find_by_id(user_id)
    unless @user && @user.token && @user.token_expiration
      flash[:error] = 'User not found or password reset not requested'
      redirect_to(root_path) and return
    end
    if @user.token_expiration < Time.now
      flash[:error] = 'Password reset token has expired. Please request a reset again.'
      redirect_to(:action => 'password_reset') and return
    end
    unless @user.token == token
      flash[:error] = 'Invalid password reset token. Please request a reset again.'
      redirect_to(:action => 'password_reset') and return
    end
    
    
    if request.post?
      password = params[:password]
      password_confirmation = params[:password_confirmation]
  
      unless legal_password(password)
        flash[:error] = 'Your password must be at least eight characters long and have at least one letter and at least one number.'
        redirect_to(complete_password_reset_path(:id => @user.id, :token => @user.token)) and return
      end
      
      unless password == password_confirmation
        flash[:error] = 'Password and confirmation do no match. Please try again.'
        redirect_to(complete_password_reset_path(:id => @user.id, :token => @user.token)) and return
      end
  
      begin
        Ldap_User.find_by_email(@user.email).change_password(password)
      rescue Exception => ex
        flash[:error] = "Problem updating password in LDAP. Please retry."
        redirect_to(complete_password_reset_path(:id => @user.id, :token => @user.token)) and return
      end
  
      @user.clear_token
      flash[:notice] = "You have successfully updated your password."
      redirect_to login_path and return
    end
  end
  
  def legal_password(password)
    (8..30).include?(password.length) and password.match(/\d/) and password.match(/[A-Za-z]/)
  end
end
