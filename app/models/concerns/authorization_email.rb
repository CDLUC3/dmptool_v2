module AuthorizationEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_role_granted
  end

  # [:users][:role_granted]
  def email_role_granted

  end
end