object @user

attributes :id, :institution_id, :first_name, :last_name, :email

child :institution do
	attributes :id, :full_name
end