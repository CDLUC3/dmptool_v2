json.array!(@resources) do |resource|
  json.extract! resource, :type, :value, :label, :requirement_id, :resource_template_id
  json.url resource_url(resource, format: :json)
end