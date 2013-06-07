module UserSessionsHelper

  def sign_in_or_create(auth_hash)
    @user = User.find_by(email: auth_hash[:info][:email])

    if @user
      flash[:notice] = 'User was found.'
    else
      @user = User.new(email: auth_hash[:info][:email], first_name: auth_hash[:info][:first_name],
                          last_name: auth_hash[:info][:last_name])

      if @user.save
        sign_in(@user)
        flash[:notice] = 'New user created.'
      else
        flash[:alert] = 'Error creating new user.'
      end
    end
  end

  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.cookie_salt]
    current_user = user
  end

  def sign_out
    cookies.delete(:remember_token)
    current_user = nil
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  def signed_in?
    !current_user.nil?
  end

  def deny_access
    redirect_to root_path
  end

  private

  def user_from_remember_token
    User.authenticate_with_salt(*remember_token)
  end

  def remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end
end
