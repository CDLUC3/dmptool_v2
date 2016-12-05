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
      "<span id=\"#{overall ? 'total' : 'new'}-#{text.downcase.gsub(' ', '-')}s\">" +
        "#{number_with_delimiter(number)}" +
      "</span>" +
      " #{overall ? 'Total' : 'New'} #{text}#{number == 1 ? '' : 's'}" + 
      "#{overall ? ' as of ' : ' for '} <span class=\"effective-month\">#{month}</span>" +
    '</div>'
  end
  
  def year_numeric_month_to_year_text_month(val)
    if val.match(/[0-9]{4}\-[0-9]{1,2}/)
      parts = val.split('-')
      "#{parts[0]}-#{Date::ABBR_MONTHNAMES[parts[1].to_i]}"
    else
      val
    end
  end

end