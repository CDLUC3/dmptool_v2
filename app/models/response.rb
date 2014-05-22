class Response < ActiveRecord::Base

  belongs_to :plan
  belongs_to :requirement

  validates :plan_id, presence: true, numericality: true
  validates :requirement_id, presence: true, numericality: true
  validates :text_value, presence: true, if: :validate_only_if_obligation_mandatory
  #after_update :associated_responses


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

  def associated_responses
    plan = Plan.find(self.plan_id)
    plan_state_id = plan.current_plan_state_id
    state = PlanState.find(plan_state_id).state
    if (state  == :committed) || (state == :approved) || (state == :rejected) || (state == :reviewed)
      if self.previous_changes != ""
        return self.id
      else
        return ""
      end
    end
  end

end
