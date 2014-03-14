object @institution

attributes :id, :full_name

node(:admins) { |institution| institution_admins(institution) }

