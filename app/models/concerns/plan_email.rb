module PlanEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_save :email_dmp_saved
  end

  # for these notifications:
  # [:dmp_owners_and_co][:commited] -- A DMP is committed
  # [:dmp_owners_and_co][:published] -- A DMP is shared
  # [:dmp_owners_and_co][:submitted] -- A submitted DMP is approved or rejected
  # [:institutional_reviewers][:submitted] -- An Institutional DMP is approved or rejected
  # [:institutional_reviewers][:approved_rejected] -- An Institutional DMP is submitted for review
  def email_dmp_saved

    #[:dmp_owners_and_co][:published] -- A DMP is shared
    if !self.changes["visibility"].nil?
      if self.changes["visibility"][0] != self.changes["visibility"][1] &&
          (self.visibility == 'institutional' || self.visibility == 'public')
        # mail all owners and co-owners
        users = self.users
        users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:published]}
        if users.length > 0
          UsersMailer.notification(
              users.collect(&:email),
              "A DMP is shared",
              "dmp_owners_and_co_published",
              { } ).deliver
        end
      end
    end


    # if the current_plan_state hasn't changed value then return now and don't mess with any of the rest
    return if self.changes["current_plan_state_id"].nil?
    earlier_state = PlanState.find(self.changes["current_plan_state_id"][1])
    current_state =  self.current_state
    return if earlier_state.state == current_state.state


    # [:dmp_owners_and_co][:commited]  -- A DMP is committed -- josh misspelled commited
    if current_state.state == 'committed'
      users = self.users
      users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:commited]} #Josh misspelled, I may need to change later
      if users.length > 0
        UsersMailer.notification(
            users.collect(&:email),
            "A DMP is committed",
            "dmp_owners_and_co_committed",
            { } ).deliver
      end

    # [:dmp_owners_and_co][:submitted] -- A submitted DMP is approved or rejected
    # [:institutional_reviewers][:approved_rejected] -- An Institutional DMP is approved or rejected
    elsif current_state.state == 'approved' || current_state.state == 'rejected'
      users = self.users
      users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:submitted]}
      if users.length > 0
        UsersMailer.notification(
            users.collect(&:email),
            "A submitted DMP is approved or rejected",
            "dmp_owners_and_co_submitted",
            { } ).deliver
      end

      institution = self.owner.institution
      users = institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_REVIEWER)
      users.delete_if {|u| !u[:prefs][:institutional_reviewers][:approved_rejected] }
      if users.length > 0
        UsersMailer.notification(
            users.collect(&:email),
            "A new comment was added",
            "institutional_reviewers_approved_rejected",
            {} ).deliver
      end

    # [:institutional_reviewers][:submitted] -- An Institutional DMP is submitted for review
    elsif current_state.state == 'submitted'
      institution = self.owner.institution
      users = institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_REVIEWER)
      users.delete_if {|u| !u[:prefs][:institutional_reviewers][:submitted] }
      if users.length > 0
        UsersMailer.notification(
            users.collect(&:email),
            "An institutional DMP is submitted for review",
            "institutional_reviewers_submitted",
            {} ).deliver
      end
    end
  end
end