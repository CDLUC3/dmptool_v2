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

    #mail all owners and co-owners for a plan that has a new comment
    users = self.plan.users
    users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:new_comment] }
    users.each do |user|
      UsersMailer.notification(
          user.email,
          "A new comment was added for your plan",
          "dmp_owners_and_co_new_comment",
          {:comment => self.value, :user_name => self.user.full_name } ).deliver
    end


    #mail All institutional reviewers for plan's institution
    institution = self.user.institution
    users = institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_REVIEWER)
    users.delete_if {|u| !u[:prefs][:institutional_reviewers][:new_comment] }
    users.each do |user|
      UsersMailer.notification(
          user.email,
          "A new comment was added",
          "institutional_reviewers_new_comment",
          {:comment => self.value, :user_name => self.user.full_name } ).deliver
    end
  end
end