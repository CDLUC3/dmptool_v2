class PlanState < ActiveRecord::Base

  belongs_to :plan
  belongs_to :user

  validates_columns :state
end
