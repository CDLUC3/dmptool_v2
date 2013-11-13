module ResourceTemplatesHelper
  def activate_link_text(resource_template)
    resource_template.active? ? 'Deactivate' : 'Activate'
  end
	def display_status_text(resource_template)
    resource_template.active? ? 'Active' : 'Inactive'
  end
end
