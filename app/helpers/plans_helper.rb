module PlansHelper
	def owner_name(plan)
		plan_id= plan.id
		user_id= UserPlan.where(plan_id: plan_id).first.user_id
		owner = User.find(user_id).full_name
		return owner
	end

	def state(plan)
		plan_state_id = plan.current_plan_state_id
		state = PlanState.find(plan_state_id).state.to_s
		return state
	end

	def plan_name(planstate)
		plan_id= planstate.plan_id
		Plan.find(plan_id).name
	end

	def plan_user(planstate)
		plan_id= planstate.user_id
		User.find(user_id).full_name
	end
end
