module RequirementsTemplateEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_save :email_template_saved
    after_destroy :email_template_destroyed
  end

  # for these notifications:
  # [:requirement_editors][:commited]
  # [:requirement_editors][:deactived]
  # [:resource_editors][:associated_commited]
  def email_template_saved

  end

  # for these notifications:
  # [:requirement_editors][:deleted]
  # [:resource_editors][:deleted]
  def email_template_destroyed

  end
end