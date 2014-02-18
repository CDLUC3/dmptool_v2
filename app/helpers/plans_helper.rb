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

	def status(plan)
		plan_state_id = plan.current_plan_state_id
		@state = PlanState.find(plan_state_id).state.capitalize
	end

	def institution_name(plan_id)
		unless !Plan.exists?(plan_id)
			requirements_template_id = Plan.where(id: plan_id).pluck(:requirements_template_id)
			institution_id = RequirementsTemplate.includes(:institution).where(id: requirements_template_id)
			institution_name = Institution.find(institution_id).full_name
		end
	end

	def instruction(requirement_id)
		unless !Requirement.exists?(requirement_id)
			Requirement.find(requirement_id).text_full
		end
	end

	def guidance(requirement_id)
		unless !Requirement.exists?(requirement_id)
			requirement = Requirement.find(requirement_id)
			@resource_contexts = ResourceContext.where(requirement_id: requirement_id, institution_id: current_user.institution_id, requirements_template_id: @requirements_template.id)
			@resource_contexts
		end
	end

	def display_text(resource_contexts)
		resources = Array.new
		resource_contexts.each do |resource_context|
			id  = resource_context.resource_id
			resource = Resource.find(id).text
			resources << resource
		end
		return resources
	end

end
