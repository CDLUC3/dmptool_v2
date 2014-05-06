module UserPlanEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_coowner_added
  end

  # [:dmp_owners_and_co][:user_added] -- I have been made a co-owner of a DMP
  def email_coowner_added
    # mail all owners and co-owners

    new_user_type = (self.owner ? 'owner': 'co-owner')
    new_user = self.user
    plan = self.plan

    users = plan.users
    users.delete_if {|u| !u.prefs[:dmp_owners_and_co][:user_added] }

    users.each do |user|
      UsersMailer.notification(
            user.email,
            "New #{new_user_type} of #{plan.name}",
            "dmp_owners_and_co_user_added",
            {:user => user, :plan => plan, :new_user => new_user, :new_user_type => new_user_type } ).deliver
    end
  end
end