module ResponsesHelper
	def requirement(requirement_id)
		@requirement = Requirement.find(requirement_id)
	end
end
