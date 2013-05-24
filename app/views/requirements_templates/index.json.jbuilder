json.array!(@requirements_templates) do |requirements_template|
  json.extract! requirements_template, :institution_id, :name, :active, :start_date, :end_date, :visibility, :version, :parent_id, :mandatory_review
  json.url requirements_template_url(requirements_template, format: :json)
end