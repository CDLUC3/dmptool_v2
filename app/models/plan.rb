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

  accepts_nested_attributes_for :comments, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
  accepts_nested_attributes_for :responses, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }

  def public?
    visibility == :public
  end

  def private?
    visibility == :private
  end

  def institutional?
    visibility == :institutional
  end

  def owned
   self.user_plans.where(owner: true)
  end

  def coowned
   self.user_plans.where(owner: false)
  end
end
