module ResourceContextEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_destroy :resource_context_destroy
  end

  # for these notifications:
  # [:resource_editors][:deleted] - A customization is deleted
  def resource_context_destroy
    #users = institution.users_in_and_above_inst_in_role(Role::TEMPLATE_EDITOR)
    #users.delete_if {|u| !u[:prefs][:requirement_editors][:deleted] }
    #users.each do |user|
    #  UsersMailer.notification(
    #      user.email,
    #      "An institutional DMP template is deleted",
    #      "requirement_editors_deleted",
    #      {} ).deliver
    #end
  end
end