object @plan

attribute  :id
attribute  :requirements_template_id => :template_id
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
              :id => :id,
              :active => :active, 
              :start_date_us_format => :start_date, 
              :end_date_us_format => :end_date, 
              :review_type => :review_type
              
              #child :resource_contexts => :customization do
               # attribute :institution_id
                #attribute :requirements_template_id => :template_id

                #child :requirements do
                 # attribute  :requirements_template_id => :template_id
                  #attribute  :text_brief
                  #attribute  :obligation
                  #child :responses do
                   # attribute :plan_id
                    #attribute :text_value, :unless => lambda { |r| r.text_value.blank?}
                    #attribute :numeric_value, :unless => lambda { |r| r.numeric_value.blank?}
                    #attribute :date_value, :unless => lambda { |r| r.date_value.blank?}
                  #end
                #end

              #end
end


 