module RequirementsHelper
  def nested_requirements(requirements)
    requirements.map do |requirement, sub_requirements|
      render(requirement) + content_tag(:div, nested_requirements(sub_requirements), :class => "nested_requirements")
    end.join.html_safe
  end
  
  def nested_requirements_view(requirements)
    requirements.map do |requirement, sub_requirements|
      render(requirement)
    end.join.html_safe
  end
end