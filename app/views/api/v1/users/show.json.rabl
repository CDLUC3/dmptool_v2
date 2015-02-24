object @user

attributes :first_name, :last_name, :email

child :institution do
	attributes :full_name
end