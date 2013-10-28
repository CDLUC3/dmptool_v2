module UsersHelper
  def password_label user
    user.new_record? ? 'Password' : 'New Password'
  end

  def fetch_user(institution)
  	role = Role.where(name: "Institutional Administrator").pluck(:id)
  	@user_id = institution.authorizations.select(:user_id).where(role_id: role)
		user_names =  User.where(id: @user_id).pluck(:first_name, :last_name).join(' ')
	end

	def fetch_id
		User.where(id: @user_id).pluck(:id)
	end
end