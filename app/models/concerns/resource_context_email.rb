module ResourceContextEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_destroy :resource_context_destroy
  end

  # for these notifications:
  # [:resource_editors][:deleted] - A customization is deleted
  def resource_context_destroy
    # only notify for customizations being deleted, not other kinds
    if !self.institution_id.nil? && self.requirement_id.nil? && self.resource_id.nil?
      institution = self.institution
      template = self.requirements_template
      users = institution.users_in_and_above_inst_in_role(Role::RESOURCE_EDITOR)
      users.delete_if {|u| !u[:prefs][:resource_editors][:deleted] }
      users.each do |user|
        UsersMailer.notification(
            user.email,
            "DMP Template Customization Deleted: #{template.name}",
            "resource_editors_deleted",
            {:user => user, :customization => self} ).deliver
      end
    end
  end
end