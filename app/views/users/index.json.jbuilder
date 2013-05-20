json.array!(@users) do |user|
  json.extract! user, :institution_id, :email, :first_name, :last_name, :token, :token_expiration, :prefs
  json.url user_url(user, format: :json)
end