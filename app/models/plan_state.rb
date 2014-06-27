class PlanState < ActiveRecord::Base

  belongs_to :plan
  belongs_to :user
  
  after_create :update_current_plan_state


  DISPLAY_STATES = {
      new: 'New',
      committed: 'Completed',
      submitted: 'Submitted',
      approved: 'Approved',
      reviewed: 'Reviewed',
      rejected: 'Rejected',
      revised: 'Revised',
      inactive: 'Inactive',
      deleted: 'Deleted'
  }

  def display_state
    return '' if self.state.nil?
    DISPLAY_STATES[self.state]
  end

  private
    def update_current_plan_state
      #update the current plan pointer in the plan model
      p = self.plan
      p.current_plan_state_id = self.id
      p.save!
    end
  
  public

  validates_columns :state
  
  ALL_STATES = ['new', 'committed', 'submitted', 'approved', 'rejected', 'revised', 'inactive', 'deleted']
  
  ACTIVE_STATES = ['new', 'committed', 'submitted', 'approved', 'rejected', 'revised']
  
  REVIEW_STATES = ['submitted', 'approved', 'rejected']
  
  PENDING_REVIEW_STATES = ['submitted']
  
  FINISHED_REVIEW_STATES = ['approved', 'rejected', 'committed']
end
