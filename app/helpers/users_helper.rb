module UsersHelper
  def password_label user
    user.new_record? ? 'Password' : 'New Password'
  end
end