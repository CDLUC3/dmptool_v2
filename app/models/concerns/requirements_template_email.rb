module RequirementsTemplateEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_save :email_template_saved
    after_destroy :email_template_destroyed
  end

  # for these notifications:
  # [:requirement_editors][:deactived] - An institutional DMP template is deactivated
  # [:requirement_editors][:commited] - An institutional DMP template is committed
  # [:resource_editors][:associated_commited] - A DMP Template associated with a customization is activated
  def email_template_saved

    # [:requirement_editors][:deactived] - An institutional DMP template is deactivated
    if self.active == false && !self.changes["active"].nil? && self.changes["active"][0] == true
      institution = self.institution
      users = institution.users_in_and_above_inst_in_role(Role::TEMPLATE_EDITOR)
      users.delete_if {|u| !u[:prefs][:requirement_editors][:deactived] }
      if users.length > 0
        UsersMailer.notification(
            users.collect(&:email),
            "An institutional DMP template is deactivated",
            "requirement_editors_deactived",
            {} ).deliver
      end

    # [:requirement_editors][:commited] - An institutional DMP template is committed (activated)
    elsif self.active == true && !self.changes["active"].nil? && self.changes["active"][0] == false
      institution = self.institution
      users = institution.users_in_and_above_inst_in_role(Role::TEMPLATE_EDITOR)
      users.delete_if {|u| !u[:prefs][:requirement_editors][:commited] }
      if users.length > 0
        UsersMailer.notification(
            users.collect(&:email),
            "An institutional DMP template is committed",
            "requirement_editors_commited",
            {} ).deliver
      end
    else

    end
  end

  # for these notifications:
  # [:requirement_editors][:deleted] - An institutional DMP template is deleted
  # -- THIS SHOULD NEVER TRIGGER SINCE IT SEEMS DELETION HAS BEEN REMOVED
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