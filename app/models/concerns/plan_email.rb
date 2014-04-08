module PlanEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_save :email_dmp_saved
  end

  # for these notifications:
  # [:dmp_owners_and_co][:commited]
  # [:dmp_owners_and_co][:published]
  # [:dmp_owners_and_co][:submitted]
  # [:institutional_reviewers][:submitted]
  # [:institutional_reviewers][:approved_rejected]
  def email_dmp_saved

  end
end