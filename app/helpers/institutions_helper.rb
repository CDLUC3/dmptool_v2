module InstitutionsHelper
  def nested_institutions(institutions)
    institutions.map do |institution, sub_institutions|
      render(institution) + content_tag(:div, nested_institutions(sub_institutions), :class => "nested_institutions")
    end.join.html_safe
  end


  def my_profile_institution_list(ins)
    if !ins.root?
      @institution_list = ins.parent.subtree.collect { |i| [i.full_name, i.id] }
    elsif ins.has_children?
      @institution_list = ins.subtree.collect { |i| [i.full_name, i.id] }
    else
      @institution_list = [[ ins.full_name, ins.id ]]
    end
  end



  def plans_count_for_institution(institution)
    Plan.joins(:requirements_template).where("requirements_templates.institution_id IN (?)", [institution.id]).count  
  end

  def institution_admins(institution)
    Authorization.joins(:user).where("users.institution_id = ? AND authorizations.role_id = ?", institution.id, 5).count
  end
  
end