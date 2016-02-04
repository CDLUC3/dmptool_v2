object @plan

attributes :id, :name
attributes :created_at => :created

child :requirements_template => :template do
  attributes  :id => :id, :name => :name
end