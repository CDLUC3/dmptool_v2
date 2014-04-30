module UserEmail
  # these concerns are for notification emails
  #extend ActiveSupport::Concern

  #included do
  #  after_create :email_role_granted
  #end

  # [:users][:role_granted]
  def email_roles_granted(granted_roles)
    # I believe this should notify the user who is granted the role
    users = [self]
    users.delete_if {|u| !u[:prefs][:users][:role_granted] } #deletes from array if not set
    users.each do |user|
      friendly_roles = Role.where(id: granted_roles).map(&:name)
      return if friendly_roles.blank?
      UsersMailer.notification(
          user.email,
          "#{friendly_roles.join(', ')} Activated",
          "users_role_granted",
          { :granted_roles => friendly_roles,
            :user => user
          } ).deliver
    end
  end
end