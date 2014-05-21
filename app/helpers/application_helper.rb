module ApplicationHelper

  #to enable column sorting with toggle effects
  #current asc and current desc classes are for supporting an eventual arrow image 
  #or css class (not yet implemented) associated with the sorting direction 
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == params[:order_scope] ? "current #{params[:direction]}" : nil
    direction = column == params[:order_scope] && params[:direction] == "asc" ? "desc" : "asc"
    link_to title, 
      {:order_scope => column, :direction => direction, :scope => @scope, :all_scope => @all_scope},
      {:class => css_class}
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', :class => "add_fields btn", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def fix_url(u)
    begin
      uri = URI.parse(str)
      uri.kind_of?(URI::HTTP)
      return u
    rescue URI::InvalidURIError
      return "http://#{u}"
    end
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
    elsif !response.numeric_value.nil? then
      return response.numeric_value.to_s
    elsif !response.date_value.nil? then
      return response.date_value.to_s
    elsif !response.text_value.nil?
      return response.text_value.html_safe
    end
  end

  def current_page_includes?(*args)
    args.each do |a|
      return true if current_page?(a)
    end
    return false
  end

  #returns the origin url, but only if it isn't set already in params
  def smart_origin_url
    if params[:origin_url].blank?
      request.original_url
    else
      params[:origin_url]
    end
  end

  #returns true or false for customization section
  def customization_section?
    current_page_includes?(edit_resource_context_path(@resource_context),
                           new_resource_context_path,
                           customization_requirement_path(@resource_context)) ||
        ( params[:controller] == 'customizations' && params[:requirement_id] &&
            current_page?(customization_requirement_path(@resource_context, requirement_id: params[:requirement_id])))
  end

  def set_page_history
    if session[:page_history].blank?
      session[:page_history] = []
    end
    if session[:page_history].length > 4
      session[:page_history].pop
    end
    session[:page_history].insert(0, request.path)
  end
end
