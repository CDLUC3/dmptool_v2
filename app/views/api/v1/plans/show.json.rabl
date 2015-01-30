object @plan

#attribute  :id
#attribute  :requirements_template_id => :template_id
attribute  :name
attribute  :solicitation_identifier, :unless => lambda { |p| p.solicitation_identifier.blank?}
attribute  :visibility
attribute  :created
attribute  :modified 

node :state do |p|
  p.current_state.state
end

node :institution do |p|
  p.owner.institution.full_name
end

child :owner => :owner do
  attributes :full_name, :email 
end


child({:coowners => :coowners}, :if => lambda { |p| p.coowners.present? }) do
  attributes :full_name, :email
end

child :requirements_template => :template do
  attributes  :name => :name, 
  #            :id => :id,
              :active => :active, 
              :start_date_us_format => :start_date, 
              :end_date_us_format => :end_date, 
              :review_type => :review_type
              
end

child :responses do
 #attribute :id 
 #attribute :plan_id 
 #attribute :requirement_id 
 attribute :text_value 

 child :requirement do
  #attribute  :id
  #attribute  :requirements_template_id => :template_id
  attribute  :text_brief
  attribute  :obligation 
 end

end

