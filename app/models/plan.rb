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
  validates :requirements_template_id, presence: true

  # scopes for plan's visibility
  scope :institutional_visibility, -> { where(visibility: :institutional) }
  scope :public_visibility, -> { where(visibility: :public) }
  scope :private_visibility, -> { where(visibility: :private) }

  # scopes for plan's states
  scope :submitted, -> { joins(:current_state).where('plan_states.state =?', :submitted) }
  scope :approved, -> { joins(:current_state).where('plan_states.state =?', :approved) }
  scope :rejected, -> { joins(:current_state).where('plan_states.state =?', :rejected) }
  scope :revised, -> { joins(:current_state).where('plan_states.state =?', :revised) }
  scope :committed, -> { joins(:current_state).where('plan_states.state =?', :committed) }


  scope :plans_to_be_reviewed, ->(institution_id) {joins(:users, :current_state).where("users.institution_id IN(?)", institution_id).where(plan_states: {state: 'submitted'}).where(user_plans: {owner: true})}

  def self.letter_range(s, e)
    #add as a scope where s=start and e=end letter
    where("name REGEXP ?", "^[#{s}-#{e}]")
  end

  def owner
    @owner ||= users.where('user_plans.owner' => true).first
  end

  def plans_count_for_institution(institution)
    Plan.where(:requirements_templates => { :institution_id => institution.subtree_ids }).count
  end

  def current_plan_state
    id  = self.current_plan_state_id
    state = PlanState.find(id).state
    return state
  end
end
