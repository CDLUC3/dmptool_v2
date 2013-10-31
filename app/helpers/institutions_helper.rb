module InstitutionsHelper
  def nested_institutions(institutions)
    institutions.map do |institution, sub_institutions|
      render(institution) + content_tag(:div, nested_institutions(sub_institutions), :class => "nested_institutions")
    end.join.html_safe
  end

  def my_profile_institution_list(ins)
    if ins.has_children? && !ins.root?
      @institution_list = ins.parent.subtree.collect { |i| [i.full_name, i.id] }
    elsif ins.has_children? && ins.root?
      @institution_list = ins.subtree.collect { |i| [i.full_name, i.id] }
    elsif !ins.has_children? && ins.root?
      @institution_list = [[ ins.full_name, ins.id ]]
    elsif !ins.has_children? && !ins.root?
       @institution_list = ins.parent.subtree.collect { |i| [i.full_name, i.id] }
    end
  end
end
