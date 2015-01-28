object @plan

attributes  :name, 
            :solicitation_identifier, 
            :visibility, 
            :created, 
            :modified 

node :state do |p|
  p.current_state.state
end

node :institution do |p|
  p.owner.institution.full_name
end

child :owner => :owner do
  attributes :full_name, :email 
end

child :coowners => :coowners do
  attributes :full_name, :email
end

child :requirements_template do
  attributes  :name => :name, 
              :active => :active, 
              :start_date_us_format => :start_date, 
              :end_date_us_format => :end_date, 
              :review_type => :review_type
end







 