module PlansHelper
	def owner_name(plan)
		plan_id= plan.id
		unless !Plan.exists?(plan_id)
			user_id = UserPlan.where(plan_id: plan_id, owner: true).first.user_id
			unless !User.exists?(user_id)
				owner = User.find(user_id).full_name
				return owner
			end
		end
	end

	def state(plan)
		plan_state_id = plan.try(:current_plan_state_id)
		unless plan_state_id.nil?
			state = PlanState.find(plan_state_id).state
			return state
		else
			return ""
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

	def institution_name(plan_id)
		unless !Plan.exists?(plan_id)
			requirements_template_id = Plan.find(plan_id).requirements_template_id
			institution_id = RequirementsTemplate.includes(:institution).find(requirements_template_id).institution_id
			institution_name = Institution.find(institution_id).full_name
			return institution_name
		end
	end

	def coowner(plan)
		coowner_ids = plan.user_plans.where(owner: false).pluck(:user_id)
		if coowner_ids.include?(@user.id)
			return true
		else
			return false
		end
	end

end
