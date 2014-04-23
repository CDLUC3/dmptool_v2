module UserPlanEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_coowner_added
  end

  # [:dmp_owners_and_co][user_added]
  def email_coowner_added

  end
end