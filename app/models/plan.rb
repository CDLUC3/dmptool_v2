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

  # scopes for plan's visibility
  scope :institutional_visibility, -> { where(visibility: :institutional) }
  scope :public_visibility, -> { where(visibility: :public) }
  scope :private_visibility, -> { where(visibility: :private) }

  # scopes for plan's states
  scope :owned, -> { joins(:user_plans).where('user_plans.owner =?', true).distinct }
  scope :coowned, -> {  joins(:user_plans).where('user_plans.owner =?', false).distinct }
  scope :submitted, -> { joins(:current_state).where('plan_states.state =?', :submitted) }
  scope :approved, -> { joins(:current_state).where('plan_states.state =?', :approved) }
  scope :rejected, -> { joins(:current_state).where('plan_states.state =?', :rejected) }
  scope :revised, -> { joins(:current_state).where('plan_states.state =?', :revised) }
  scope :committed, -> { joins(:current_state).where('plan_states.state =?', :committed) }
end
