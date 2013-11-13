class PlanState < ActiveRecord::Base

  belongs_to :plan
  belongs_to :user
  
  after_create :update_current_plan_state

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
