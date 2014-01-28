module PlansHelper
	def owner_name(plan)
		plan_id= plan.id
		unless !Plan.exists?(plan_id)
			user_id = UserPlan.where(plan_id: plan_id, owner: true).first.user_id
			owner = User.find(user_id).full_name
			return owner
		end
	end

	def state(plan)
		plan_state_id = plan.current_plan_state_id
		unless plan_state_id.nil?
			state = PlanState.find(plan_state_id).state.to_s
			return state
		end
	end

	def plan_name(planstate)
		plan_id = planstate.plan_id
		unless !Plan.exists?(plan_id)
			Plan.find(plan_id).name
		end
	end

	def plan_user(planstate)
		plan_id = planstate.plan_id
		unless !Plan.exists?(plan_id)
			user_id = UserPlan.where(plan_id: plan_id).first.user_id
			User.find(user_id).full_name
		end
	end
end
