json.array!(@resource_contexts) do |resource_context|
  json.extract! resource_context, :institution_id, :requirements_template_id,:requirement_id, :name, :review_type, :contact_email, :contact_info, :created_at, :updated_at
  json.url resource_context_url(resource_context, format: :json)
end




