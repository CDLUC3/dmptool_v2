class Plan < ActiveRecord::Base

  has_many :user_plans
  has_many :users, through: :user_plans
  has_many :plan_states
  has_many :published_plans
  has_many :comments
  has_many :responses
  has_one  :current_state,
           :class_name => 'PlanState',
           :primary_key => 'current_plan_state_id',
           :foreign_key => 'id'
  belongs_to :requirements_template

  validates_columns :visibility
  validates :name, presence: true
  validates :visibility, presence: true

  def public?
    visibility == :public
  end

  def public_browsable?
    visibility == :public_browsable
  end

  def institutional?
    visibility == :institutional
  end
end
