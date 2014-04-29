module ResourceContextEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_destroy :resource_context_destroy
  end

  # for these notifications:
  # [:resource_editors][:deleted] - A customization is deleted
  def resource_context_destroy

  end
end