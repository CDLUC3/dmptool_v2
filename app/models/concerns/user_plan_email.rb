module UserPlanEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_coowner_added
  end

  # [:dmp_owners_and_co][:user_added]
  def email_coowner_added
    # mail all owners and co-owners
    if self.owner == false
      users = self.users
      users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:user_added] || u.id = self.user_id }

      users.each do |user|
        UsersMailer.notification(
            user.email,
            "A co-owner has been added",
            "dmp_owners_and_co_user_added",
            { } ).deliver
      end
    end
  end
end