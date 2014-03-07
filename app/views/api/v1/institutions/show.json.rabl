object @institution

attributes :id, :full_name, :contact_email

node(:plans_count) { |institution| plans_count_for_institution(institution) }

node(:admins) { |institution| institution_admins(institution) }






