json.array!(@institutions) do |institution|
  json.extract! institution, :full_name, :nickname, :desc, :contact_info, :contact_email, :url, :url_text, :shib_entity_id, :shib_domain
  json.url institution_url(institution, format: :json)
end