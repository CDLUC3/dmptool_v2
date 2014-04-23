module ResourcesHelper
	def resource_type(resource_context)
		if resource_context.resource.nil?
			return " "
		elsif resource_context.resource.resource_type == :help_text
			return "Guidance"
		elsif resource_context.resource.resource_type == :actionable_url
			return "Links"
		elsif resource_context.resource.resource_type == :suggested_response
			return "Suggested Response"
		elsif resource_context.resource.resource_type == :example_response
			return "Example Response"
		end
	end
end
