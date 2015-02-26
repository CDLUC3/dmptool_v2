object @plan

#attribute  :id
attribute  :name
attribute  :solicitation_identifier, :unless => lambda { |p| p.solicitation_identifier.blank?}
attribute  :visibility
attribute  :created
attribute  :modified 


node :state do |p|
  p.current_state.state
end

#node :institution do |p|
node({:institution => :institution}, :if => lambda { |p| p.owner.present? }) do |p|
  p.owner.institution.full_name
end

#child :owner => :owner do
child({:owner => :owner}, :if => lambda { |p| p.owner.present? }) do
  attributes :full_name, :email 
end


child({:coowners => :coowners}, :if => lambda { |p| p.coowners.present? }) do
  attributes :full_name, :email
end


child :requirements_template => :template do
  attributes  :name => :name, 
              :active => :active, 
              :start_date_us_format => :start_date, 
              :end_date_us_format => :end_date, 
              :review_type => :review_type
              
end









