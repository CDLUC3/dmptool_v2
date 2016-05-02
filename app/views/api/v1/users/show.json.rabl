object @user

attributes :first_name, :last_name, :email, :created

child :institution do
	attributes :full_name
end