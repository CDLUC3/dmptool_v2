class Plan < ActiveRecord::Base

  include PlanEmail
  attr_accessor :current_user_id
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
  validate :unique_plan_name_per_owner, on: :create

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
  scope :reviewed, -> { joins(:current_state).where('plan_states.state =?', :reviewed) }

  # scopes for Plan Review
  scope :plans_to_be_reviewed, ->(institution_id) {joins(:users, :current_state).where("users.institution_id IN(?)", institution_id).where(plan_states: {state: 'submitted'}).where(user_plans: {owner: true})}
  scope :plans_approved, ->(institution_id) {joins(:users, :current_state).where("users.institution_id IN(?)", institution_id).where(plan_states: {state: 'approved'}).where(user_plans: {owner: true})}
  scope :plans_rejected, ->(institution_id) {joins(:users, :current_state).where("users.institution_id IN(?)", institution_id).where(plan_states: {state: 'rejected'}).where(user_plans: {owner: true})}
  scope :plans_reviewed, ->(institution_id) {joins(:users, :current_state).where("users.institution_id IN(?)", institution_id).where(plan_states: {state: 'reviewed'}).where(user_plans: {owner: true})}
  scope :plans_per_institution, ->(institution_id) {joins(:users, :current_state).where("users.institution_id IN(?)", institution_id).where(plan_states: {state: ['rejected', 'approved', 'submitted', 'reviewed']}).where(user_plans: {owner: true})}

  def self.letter_range(s, e)
    #add as a scope where s=start and e=end letter
    where("name REGEXP ?", "^[#{s}-#{e}]")
  end

  def self.search_terms(terms)
    items = terms.split
    conditions1 = items.map{|item| "plans.name LIKE ?" }
    conditions2 = items.map{|item| "requirements_templates.name LIKE ?" }
    conditions3 = items.map{|item| "institutions.full_name LIKE ?" }
    conditions4 = items.map{|item| "users.last_name LIKE ?" }
    conditions5 = items.map{|item| "users.first_name LIKE ?" }
    conditions = "(
                      (#{conditions1.join(' AND ')})" + ' OR ' +
                      "(#{conditions2.join(' AND ')})" + ' OR ' +
                      "(#{conditions3.join(' AND ')})" + ' OR ' +
                      "(#{conditions4.join(' OR ')})" + ' OR ' +
                      "(#{conditions5.join(' OR ')})
                  )"
    values = items.map{|item| "%#{item}%" }
    joins({:users  => :institution}, :requirements_template).
        where(user_plans: {owner: true}).
        where(conditions, *(values * 5) )
  end

  def unique_plan_name_per_owner
    user_id = self.current_user_id
    plan_names = Plan.joins(:users).where(user_plans: {owner: true}).where('users.id =?', user_id).pluck('plans.name')
    if plan_names.include?(self.name)
      errors[:base] << "A Plan with this name already exists in the list of Plans you own."
    end
  end

  def self.order_by_institution
    joins({:users  => :institution}).where(user_plans: {owner: true}).order('institutions.full_name ASC')
  end

  def self.order_by_owner
    joins(:users).where(user_plans: {owner: true}).order('users.first_name ASC', 'users.last_name ASC')
  end

  def self.order_by_current_state
    joins(:current_state).order('CONVERT(plan_states.state USING utf8)')
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
