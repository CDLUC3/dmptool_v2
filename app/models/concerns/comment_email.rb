module CommentEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_create :email_new_comment
  end

  # for both dmp_owners_and_co and institutional reviewers
  # [:dmp_owners_and_co][:new_comment]
  # [:institutional_reviewers][:new_comment]
  def email_new_comment

  end
end