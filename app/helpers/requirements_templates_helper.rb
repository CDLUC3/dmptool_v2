module RequirementsTemplatesHelper
  def activate_link_text(requirements_template)
    requirements_template.active? ? 'Deactivate' : 'Activate'
  end
	def display_status_text(requirements_template)
    requirements_template.active? ? 'Active' : 'Inactive'
  end
  def referer_action
    @referer_url = Rails.application.routes.recognize_path(URI((session[:page_history].blank? ? "": session[:page_history][0])).path)
  end
end
