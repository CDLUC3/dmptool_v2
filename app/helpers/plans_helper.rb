module PlansHelper

	def state(plan)
		plan_state_id = plan.current_plan_state_id
		state=  PlanState.find(plan_state_id).state.to_s
		return state
	end
end
