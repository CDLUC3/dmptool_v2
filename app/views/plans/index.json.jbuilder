json.array!(@plans) do |plan|
  json.extract! plan, :name, :requirements_templates_id, :solicitation_identifier, :submission_deadline, :visibility
  json.url plan_url(plan, format: :json)
end