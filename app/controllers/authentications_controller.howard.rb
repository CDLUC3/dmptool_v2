class AuthenticationsController < ApplicationController

  #for a provider/uid pair
  #-if there is an Authentication then log in as that user
  #-if there is a current user but no Authentication then add one for that user and this provider uid/pair
  # this is what can ultimately provide for transportation between identities, e.g. if someone changes institutions,
  # by having multiple Authentications for the same user. Note that if we eventually implement this we should also
  # have a way for users to manage (e.g. delete) authentications associated with their user.
  #-if the provider is ldap and there is a user with the same email (but no ldap Authentication) then
  #create an Authentication and login as that user
  #-otherwise create a user from the authentication information, create an Authentication for that user
  #and the provider, and log in as that user. Since we don't have things like the first and last name, in this
  #case redirect to the view where the user can edit those things, hoping he or she will do so.
  def create
    authentication = request.env['omniauth.auth']
    Rails.logger.error(authentication.to_s)
    request.env.keys.sort.each do |key|
      Rails.logger.error("#{key}: #{request.env[key]}")
    end

    #HADING - fix up some stuff for how we expect the authentication to come back, just
    #for development
    #authentication['info']['email'] ||= 'hding2@illinois.edu'
    #authentication['info']['domain'] ||= 'illinois.edu'

    preprocess_for_provider(authentication)
    auth = Authentication.find_by_provider_and_uid(authentication['provider'], authentication['uid'])
    if auth
      login_user(auth.user)
    elsif current_user
      Authentication.create(:user => current_user, :uid => authentication['uid'], :provider => authentication['provider'])
      #elsif authentication['provider'] == 'ldap' and (user = User.find_by_email(authentication['user_info']['email']))
      #  Authentication.create(:user => user, :uid => authentication['uid'], :provider => 'ldap')
      #  login_user(user)
    elsif  user = User.find_by_email(authentication['info']['email'])
      Authentication.create(:user => user, :uid => authentication['uid'], :provider => authentication['provider'])
      login_user(user)
    else
      user = new_user(authentication)
      login_user(user)
      flash[:notice] = "You have successfully created an account. Please update your personal details if necessary."
      if authentication['provider'] == 'shibboleth'
        redirect_to finish_signup_user_url(user, :protocol => 'https') and return
      end
    end
    redirect_to dashboard_url(:protocol => 'https')
  end

  def failure
    reset_session
    flash[:notice] = 'Login Unsuccessful'
    redirect_to params[:message].match(/Shibboleth/) ? institutional_login_url : login_url
  end

  protected

  #We need this, for example, because we're using the email for ldap to be the uid, but
  #the ldap server returns something different
  def preprocess_for_provider(authentication)
    case authentication['provider']
      when 'ldap'
        authentication['user_info']['email'] = ldap_extra_field(authentication, :mail)
        authentication['uid'] = ldap_extra_field(authentication, :uid)
        authentication['user_info']['first_name'] = ldap_extra_field(authentication, :givenname)
        authentication['user_info']['last_name'] = ldap_extra_field(authentication, :sn)
      when 'shibboleth'

      else
        #do nothing
    end
  end

  def ldap_extra_field(authentication, key)
    authentication['extra'][key].first.to_s
  end

  def find_institution(authentication)
    case authentication['provider']
      when 'ldap'
        Institution.non_partner_institution
      when 'shibboleth'
        Institution.find_by_shib_domain(domain(authentication['uid']))
    end
  end

  def domain(shibboleth_uid)
    return shibboleth_uid.split('@').last
  end

  def new_user(authentication)
    User.transaction do
      user_info = authentication['info']
      User.new(:email => user_info['email'], :first_name => user_info['first_name'] || 'New',
               :last_name => user_info['last_name'] || 'User').tap do |user|
        #instituion_id can't be mass assigned
        user.institution_id = find_institution(authentication).id
        user.ldap_create = true if authentication['provider'] == 'ldap'
        user.save!
        Authentication.create(:user => user, :uid => authentication['uid'], :provider => authentication['provider'])
      end
    end
  end

end
