class PlanState < ActiveRecord::Base

  belongs_to :plan
  belongs_to :user

  validates_columns :state
  
  REVIEW_STATES = ['submitted', 'approved', 'rejected']
  
  PENDING_REVIEW_STATES = ['submitted']
  
  FINISHED_REVIEW_STATES = ['approved', 'rejected']
end
