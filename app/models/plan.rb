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

  scope :institutional_visibility, -> { where(visibility: :institutional) }
  scope :public_visibility, -> { where(visibility: :public) }
  scope :private_visibility, -> { where(visibility: :private) }

  def shared
    self.user_plans.count > 1
  end

  def owned
   self.user_plans.where(owner: true)
  end

  def coowned
   self.user_plans.where(owner: false)
  end
end
