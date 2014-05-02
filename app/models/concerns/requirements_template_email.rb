module RequirementsTemplateEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_save :email_template_saved
  end

  # for these notifications:
  # [:requirement_editors][:deactived] - An institutional DMP template is deactivated
  # [:requirement_editors][:committed] - An institutional DMP template is activated
  # [:resource_editors][:associated_committed] - A DMP Template associated with a customization is activated
  def email_template_saved

    # [:requirement_editors][:deactived] - An institutional DMP template is deactivated
    if self.active == false && !self.changes["active"].nil? && self.changes["active"][0] == true
      institution = self.institution
      users = institution.users_in_and_above_inst_in_role(Role::TEMPLATE_EDITOR)
      users += institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_ADMIN)
      users.uniq! #only the unique users, so each user is only listed once
      users.delete_if {|u| !u[:prefs][:requirement_editors][:deactived] }
      users.each do |user|
        UsersMailer.notification(
            user.email,
            "DMP Template Deactivated: #{self.name}",
            "requirement_editors_deactived",
            {:user => user, :template => self} ).deliver
      end

    # [:requirement_editors][:committed] - An institutional DMP template is activated (committed)
    # [:resource_editors][:associated_committed] - A DMP Template associated with a customization is activated
    elsif self.active == true && !self.changes["active"].nil? && self.changes["active"][0] == false
      # this is for requirement editors
      institution = self.institution
      users = institution.users_in_and_above_inst_in_role(Role::TEMPLATE_EDITOR)
      users += institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_ADMIN)
      users.uniq! #only the unique users, so each user is only listed once
      users.delete_if {|u| !u[:prefs][:requirement_editors][:committed] }
      users.each do |user|
        UsersMailer.notification(
            user.email,
            "DMP Template Activated: #{self.name}",
            "requirement_editors_committed",
            {:user => user, :template => self} ).deliver
      end

      #this is for customizations and resource editors associated them that use this template
      # customization type 'Container - Institution',
      # inst: set,     req_temp: set,     req: not set,     resource: not set
      customizations = ResourceContext.where("institution_id IS NOT NULL AND requirement_id IS NULL AND resource_id IS NULL").
                                       where(requirements_template_id: self.id)

      #for each customization that uses this resource template that has been made active notify resource editors
      customizations.each do |customization|
        institution = customization.institution
        users = institution.users_in_and_above_inst_in_role(Role::RESOURCE_EDITOR)
        users += institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_ADMIN)
        users.uniq! #only the unique users, so each user is only listed once
        users.delete_if {|u| !u[:prefs][:resource_editors][:associated_committed] }
        users.each do |user|
          UsersMailer.notification(
              user.email,
              "DMP Template Activated: #{self.name}",
              "resource_editors_associated_committed",
              {:user => user, :template => self, :customization => customization} ).deliver
        end

      end

    end
  end
end