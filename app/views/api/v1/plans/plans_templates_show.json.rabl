object @plan

attributes :id
attributes :created_at => :created

child :requirements_template => :template do
  attributes  :id => :id, :name => :name
end