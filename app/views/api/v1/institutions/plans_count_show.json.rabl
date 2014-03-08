object @institution

attributes :id, :full_name

node(:plans_count) { |institution| plans_count_for_institution(institution) }
