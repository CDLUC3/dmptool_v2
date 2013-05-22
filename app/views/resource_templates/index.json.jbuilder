json.array!(@resource_templates) do |resource_template|
  json.extract! resource_template, :institution_id, :requirements_template_id, :name, :active, :mandatory_review, :widget_url
  json.url resource_template_url(resource_template, format: :json)
end