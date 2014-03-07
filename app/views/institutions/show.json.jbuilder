json.extract! @institution, :full_name, :nickname, :desc, :contact_info, :contact_email, :url, :url_text, :shib_entity_id, :shib_domain, :created_at, :updated_at



#json.requirements_templates @institution.joins(:requirements_templates, :plans).
 #   where(:requirements_templates => { :institution_id => self.subtree_ids }).
  #  group(:plan_id)

