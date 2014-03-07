object @institution

attributes :id, :full_name

node(:plans_count) { @plans_count }


#child :requirements_templates do
#  attributes :id
#end


#object false
#child(@institution) { attributes :id, :full_name }
#node(:plans_count) {@plans_count}


