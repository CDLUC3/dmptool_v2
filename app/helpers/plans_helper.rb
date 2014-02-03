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

	def requirements_template(requirements_template_id)
		requirements_template_id = requirements_template_id
		unless requirements_template_id.nil?
			requirements_template_name = RequirementsTemplate.find(requirements_template_id).name
		end
	end

	def owner_role(plan)
		plan = plan
		user_id = UserPlan.where(plan_id: plan.id, owner: true).first.user_id
		if user_id == current_user.id
			return true
		end
	end
end
