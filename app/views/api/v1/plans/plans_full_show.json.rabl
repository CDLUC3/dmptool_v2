object @plan

attribute  :id
attribute  :name
attribute  :solicitation_identifier, :unless => lambda { |p| p.solicitation_identifier.blank?}
attribute  :visibility
attribute  :created
attribute  :modified 

parent = root_object

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
              :active => :active, 
              :start_date_us_format => :start_date, 
              :end_date_us_format => :end_date, 
              :review_type => :review_type

              child :requirements do
                attributes :text_brief, :text_full
                node(:response) { |req|  req.response_text(parent)  }
              end
              
end
