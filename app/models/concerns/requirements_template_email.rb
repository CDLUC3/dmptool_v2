module RequirementsTemplateEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_save :email_template_saved
    after_destroy :email_template_destroyed
  end

  # for these notifications:
  # [:requirement_editors][:commited] - An institutional DMP template is committed
  # [:requirement_editors][:deactived] - An institutional DMP template is deactivated
  # [:resource_editors][:associated_commited] - A DMP Template associated with a customization is activated
  def email_template_saved



  end

  # for these notifications:
  # [:requirement_editors][:deleted] - An institutional DMP template is deleted
  def email_template_destroyed
    institution = self.institution
    users = institution.users_in_and_above_inst_in_role(Role::TEMPLATE_EDITOR)
    users.delete_if {|u| !u[:prefs][:requirement_editors][:deleted] }
    if users.length > 0
      UsersMailer.notification(
          users.collect(&:email),
          "An institutional DMP template is deleted",
          "requirement_editors_deleted",
          {} ).deliver
    end
  end
end