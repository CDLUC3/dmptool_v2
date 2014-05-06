module RequirementsTemplatesHelper
  def activate_link_text(requirements_template)
    requirements_template.active? ? 'Deactivate' : 'Activate'
  end
	def display_status_text(requirements_template)
    requirements_template.active? ? 'Active' : 'Inactive'
  end

  def is_referer_new_action?
  	referer_url = Rails.application.routes.recognize_path(URI(request.referer || "").path)
  	referer_url[:controller] == 'requirements_templates' && referer_url[:action] == 'new'
	end
end
