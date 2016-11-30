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
    Plan.joins(:users).where(user_plans: {owner: true}).where("users.institution_id = ?", institution.id).count 
  end


  def institution_admins(institution)
    Authorization.joins(:user).where("users.institution_id = ? AND authorizations.role_id = ?", institution.id, 5).count
  end
 
  
  def usage_card_content(text, number, month, overall = false)
    '<div class="statistic-card">' +
      "#{number_with_delimiter(number)} #{overall ? 'Total' : 'New'} " +
      "#{text}#{number == 1 ? '' : 's'}" + "#{overall ? '' : " For #{month}"}" +
    '</div>'
  end

end