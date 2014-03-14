module ApplicationHelper
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', :class => "add_fields btn", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def fix_url(u)
    uu = URI.parse(u)
    if(!uu.scheme)
      return "http://" + u
    end
    u
  end


  def bootstrap_class_for flash_type
    case flash_type
    when :success
    "alert-success"
    when :error
    "alert-error"
    when :alert
    "alert-block"
    when :notice
    "alert-info"
    else
    flash_type.to_s
    end
  end

  def response_value_s(response)
    if response.nil? then
      return "[No response]"
    elsif !response.numeric_value.blank? then
      return response.numeric_value.to_s
    elsif !response.date_value.blank? then
      # TODO - format ?
      return response.date_value.to_s
    else
      return response.text_value.html_safe
    end
  end
end
