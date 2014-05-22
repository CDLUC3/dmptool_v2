class Response < ActiveRecord::Base

  belongs_to :plan
  belongs_to :requirement

  validates :plan_id, presence: true, numericality: true
  validates :requirement_id, presence: true, numericality: true
  validates :text_value, presence: true, if: :validate_only_if_obligation_mandatory
  after_update :check_revised

  def validate_only_if_obligation_mandatory
  	requirement_id = self.requirement_id
  	obligation = Requirement.find(requirement_id).obligation
    requirement_type = Requirement.find(requirement_id).requirement_type
  	if obligation == :mandatory && requirement_type == :text
  		return true
  	else
  		return false
  	end
  end

  def update_with_conflict_validation(*args)
    update(*args)
  rescue ActiveRecord::StaleObjectError
      flash[:error] = "This record changed while you were editing."
      false
  end

  def check_revised
    if self.changed?
      plan = Plan.find(self.plan_id)
      plan_state_id = plan.current_plan_state_id
      state = PlanState.find(plan_state_id).state
      if (state  == :committed) || (state == :approved) || (state == :rejected) || (state == :reviewed)
        ps = PlanState.new({plan_id: plan.id, state: 'revised', user_id: plan.current_user_id })
        ps.save
      end
    end
  end

end
