module UserPlanEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_coowner_added
  end

  # [:dmp_owners_and_co][:user_added] -- I have been made a co-owner of a DMP
  def email_coowner_added
    # mail all owners and co-owners
    if self.owner == false
      coowner = User.find(self.user_id)

      if coowner.prefs[:dmp_owners_and_co][:user_added] == true
        UsersMailer.notification(
              coowner.email,
              "You've been added as a coowner",
              "dmp_owners_and_co_user_added",
              { } ).deliver
      end
    end
  end
end