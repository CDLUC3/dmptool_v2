object @plan

attributes :id
attributes :created_at => :created
attributes :visibility

child :requirements_template => :template do
  attributes  :id => :id, :name => :name
end