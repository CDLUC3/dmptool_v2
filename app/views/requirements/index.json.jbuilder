json.array!(@requirements) do |requirement|
  json.extract! requirement, :position, :parent_requirement, :text_brief, :text_full, :requirement_type, :obligation, :default, :requirements_template_id, :parent_id
  json.url requirement_url(requirement, format: :json)
end