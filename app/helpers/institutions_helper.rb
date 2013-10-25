module InstitutionsHelper
  def nested_institutions(institutions)
    institutions.map do |institution, sub_institutions|
      render(institution) + content_tag(:div, nested_institutions(sub_institutions), :class => "nested_institutions")
    end.join.html_safe
  end
end
