module ResourceTemplatesHelper
  def activate_link_text(resource_template)
    resource_template.active? ? 'Deactivate' : 'Activate'
  end
	def display_status_text(resource_template)
    resource_template.active? ? 'Active' : 'Inactive'
  end
  def remove_resource_editor_role(user)
  	@remove_role = @institution.authorizations.where(role_id: @role_id, user_id: user )
  		@remove_role.delete_all
  end
end
