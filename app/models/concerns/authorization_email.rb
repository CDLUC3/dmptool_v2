module AuthorizationEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_role_granted
  end

  # [:users][:role_granted]
  def email_role_granted
    # I believe this should notify the user who is granted the role
    users = [self.user]
    users.delete_if {|u| !u[:prefs][:users][:role_granted] } #deletes from array if not set
    if users.length > 0
      UsersMailer.notification(
          users.collect(&:email),
          "You've been given a role",
          "users_role_granted",
          nil).deliver
    end
  end
end