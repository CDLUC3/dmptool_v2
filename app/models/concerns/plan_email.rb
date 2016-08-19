module PlanEmail
  # these concerns are for notification emails
  extend ActiveSupport::Concern

  included do
    after_save :email_dmp_saved
  end

  # for these notifications:
  # [:dmp_owners_and_co][:committed] -- A DMP is completed (committed)
  # [:dmp_owners_and_co][:vis_change] -- A DMP's visibility has changed
  # [:dmp_owners_and_co][:submitted] -- A submitted DMP is approved or rejected
  # [:institutional_reviewers][:submitted] -- An Institutional DMP is approved or rejected
  # [:institutional_reviewers][:approved_rejected] -- An Institutional DMP is submitted for review
  def email_dmp_saved

    #[:dmp_owners_and_co][:vis_change] -- A DMP's visibility has changed
    if !self.changes["visibility"].nil?
      if self.changes["visibility"][0] != self.changes["visibility"][1]
        # mail all owners and co-owners
        users = self.users
        users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:vis_change]}
        users.each do |user|
          UsersMailer.notification(
              user.email,
              "DMP Visibility Changed: #{self.name}",
              "dmp_owners_and_co_vis_change",
              {user: user, 
               plan: self,
               contact_us_url: APP_CONFIG['contact_us_url'] } ).deliver
        end
      end
    end


    # if the current_plan_state hasn't changed value then return now and don't mess with any of the rest
    return if self.changes["current_plan_state_id"].nil?
    if self.changes["current_plan_state_id"][0].nil?
      earlier_state = PlanState.new
    else
      earlier_state = PlanState.find(self.changes["current_plan_state_id"][0])
    end
    current_state = self.current_state

    return if earlier_state.state == current_state.state

    # [:dmp_owners_and_co][:committed]  -- A DMP is completed (activated)
    if current_state.state == :committed
      users = self.users
      users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:committed]}
      users.each do |user|
        UsersMailer.notification(
            user.email,
            "PLAN COMPLETED: #{self.name}",
            "dmp_owners_and_co_committed",
            {user: user, 
             plan: self,
             contact_us_url: APP_CONFIG['contact_us_url'] } ).deliver
      end

    # [:dmp_owners_and_co][:submitted] -- A submitted DMP is approved or rejected
    # [:institutional_reviewers][:approved_rejected] -- An Institutional DMP is approved or rejected
    elsif current_state.state == :approved || current_state.state == :rejected || current_state.state == :reviewed
      users = self.users
      users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:submitted]}
      users.each do |user|
        UsersMailer.notification(
            user.email,
            "DMP #{current_state.state}: #{self.name}",
            "dmp_owners_and_co_submitted",
            { user: user, 
              plan: self, 
              state: current_state,
              contact_us_url: APP_CONFIG['contact_us_url'] } ).deliver
      end

      institution = self.owner.institution
      users = institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_REVIEWER)
      users.delete_if {|u| !u[:prefs][:institutional_reviewers][:approved_rejected] }
      users.each do |user|
        UsersMailer.notification(
            user.email,
            "DMP #{current_state.state}: #{self.name}",
            "institutional_reviewers_approved_rejected",
            { user: user, 
              plan: self, 
              state: current_state, 
              contact_us_url: APP_CONFIG['contact_us_url'] } ).deliver
      end

    # [:institutional_reviewers][:submitted] -- An Institutional DMP is submitted for review
    elsif current_state.state == :submitted
      institution = self.owner.institution
      
      # Send the owner and coowners a confirmation message
      users = self.users
      users.delete_if {|u| !u[:prefs][:dmp_owners_and_co][:submitted]}
      users.each do |user|
        UsersMailer.notification(
            user.email,
            (institution.submission_mailer_subject.nil? ? build_email_message(APP_CONFIG['mailer_submission_default']['subject'], false) : build_email_message(institution.submission_mailer_subject, false)),
            "dmp_owners_and_co_submitted",
            {user: user, 
             plan: self, 
             body: (institution.submission_mailer_body.nil? ? build_email_message(APP_CONFIG['mailer_submission_default']['body'], true) : build_email_message(institution.submission_mailer_body, true)), 
             state: current_state,
             contact_us_url: APP_CONFIG['contact_us_url']} 
        ).deliver
      end
      
      # Send the reviewers a notification
      users = institution.users_in_and_above_inst_in_role(Role::INSTITUTIONAL_REVIEWER)
      users.delete_if {|u| !u[:prefs][:institutional_reviewers][:submitted] }
      users.each do |user|
        UsersMailer.notification(
            user.email,
            "DMP #{current_state.state}: #{self.name}",
            "institutional_reviewers_submitted",
            {user: user, 
             plan: self, 
             state: current_state,
             contact_us_url: APP_CONFIG['contact_us_url']} 
        ).deliver
      end
    end
  end
  
  private
    # Swap out personalization phrases with their erb counterparts
    def build_email_message(template, include_boilerplate)
      unless template.nil?
        template.gsub('[User Name]', '<%= @vars[:user].full_name %>')
        template.gsub('[Plan Name]', '<%= @vars[:plan].name %>')
        template.gsub('[Plan Url]', '<%= edit_plan_url(@vars[:plan]) %>')
      
        if include_boilerplate
          template += "<br /><br /><%= render :partial => 'users_mailer/notification_boilerplate.text.erb' %>"
        end
      end
        
      template
    end
end