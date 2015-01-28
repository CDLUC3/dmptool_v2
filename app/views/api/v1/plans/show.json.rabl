object @plan

attributes :id, :name, :solicitation_identifier, :visibility, :created_at, :updated_at

#node(:owner) { |p| @plan.owner.full_name }

node :owner do |p| 
  p.owner.full_name 
end

child :current_state do
  attributes :state
end

child :requirements_template do
  attributes :id, :institution_id, :name, :active, :start_date, :end_date, :review_type
end

child :coowners => :coowners do
  attributes :full_name
end





 