# -*- mode: ruby -*-
require 'nokogiri'

@text_types = ['b', 'strong', 'i', 'em', 'u', 's', 'sup', 'sub', 'text', 'br', 'a']

@text_styles = {'b' => :bold, 'strong' => :bold, 'i' => :italic, 'em' => :italic,
                'u' => :underline, 's' => :strikethrough, 'sup' => :superscript,
                'sub' => :subscript }

def mk_formatted_text(n, styles = [])

  case
  when @text_styles.keys.include?(n.name)
    n.children.map{|c| mk_formatted_text(c, styles.push(@text_styles[n.name])) }
  when n.name == "text"
    {:text => n.text.gsub(/[\r\n\t]/, ''), :styles => styles}
  when n.name == "br"
    {:text => "\n" }
  when n.name == "a"
    {:text => "#{n.text} (#{n['href']})",
      :styles => styles.merge([:underline])}
  else
    #raise Exception.new("Unexpected tag: #{n.name}.")
    {:text => n.text,
       :styles => styles}
  end
end

def mk_formatted_texts(n)
  my_texts = n.map do |c|
    if @text_types.include?(c.name)
      mk_formatted_text(c)
    else
      nil
    end
  end
  my_texts.reject(&:nil?).flatten
end

def render_html(pdf, n, temp_state={})
  state = temp_state.dup
  case n.name
  when "document", "html", "body"
    n.children.each do |c|
      render_html(pdf, c)
    end
  when "p"
    pdf.formatted_text(mk_formatted_texts(n.children))
  when "ul"
    pdf.indent(10) do
      n.element_children.each do |li|
        render_html(pdf, li, {:list_mode=>:ul})
      end
    end
  when "ol"
    state[:list_level] = (state[:list_level] || 0) + 1
    state[:list_mode] = :ol
    pdf.indent(10) do
      n.element_children.each_with_index do |li, idx|
        render_html(pdf, li, state.merge({:index => idx + 1}))
      end
    end
  when "li"
    pdf.move_down 5
    if state[:list_mode] == :ul
      out_marker = "\u2022"
    else #ol
      out_marker = "#{state[:index]}."
    end
    pdf.float do
      pdf.bounding_box([-30, pdf.cursor], :width => 30) do
        pdf.text out_marker, :align => :right
      end
    end
    pdf.indent(10) do
      texty_children = []
      n.children.each do |child|
        if @text_types.include?(child.name)
          texty_children.push(child)
        else
          pdf.formatted_text(mk_formatted_texts(texty_children)) if texty_children.length > 0
          texty_children = []
          render_html(pdf, child, state)
        end
      end
      pdf.formatted_text(mk_formatted_texts(texty_children)) if texty_children.length > 0
    end
  when "hr"
    pdf.stroke_horizontal_rule
  else
    if !n.text.blank? then
      pdf.formatted_text([mk_formatted_text(n)])
    end
  end
end

def print_responses(pdf, requirement, heading)
  pdf.pad(12) do
    pdf.font_size(14)
    pdf.font("Helvetica", :style=>:normal)
    pdf.formatted_text([{:text=> heading, :styles=>[:normal]},
                        {:text=> " #{requirement.text_brief.to_s}", :styles=>[:bold]}])
    if requirement.children.size > 0 then
      pdf.indent(12) do
        requirement.children.order(:position).each_with_index do |child, i|
          print_responses(pdf, child, "")
        end
      end
    else
      html = Nokogiri::HTML(requirement.response_html(@plan))
      pdf.font("Helvetica", :style=>:normal)
      pdf.pad(10) do
        pdf.indent(12) do
          render_html(pdf, html)
        end
      end
    end
  end
end


pdf = Prawn::Document.new(:bottom_margin=>50, :top_margin=>60, :left_margin=>50) do |pdf|
  @cover = false
  if @plan.visibility == :public

    @cover = true

    pdf.stroke do
      pdf.fill_color "808080"
      pdf.stroke_color "808080"
      pdf.rectangle [0, 702], 518, 3
      pdf.fill
    end

    pdf.fill_color "000000"
    pdf.stroke_color "000000"

    pdf.move_cursor_to 662

    pdf.font_size(20)

    pdf.span(350, :position => :center) do
       pdf.text(@plan.name, :style => :bold, :align => :center, :position => :center)
    end
    
    pdf.move_down 14

    pdf.font_size(14)

    pdf.span(350, :position => :center) do
      pdf.text("A Data management plan created using the DMPTool", :style => :italic)
    end


    @coowners = @plan.coowners

    @coowners.length>0 ? @separator=", " : @separator=""  

    pdf.move_down 35
    pdf.text("Creator(s): " + @plan.owner.full_name + @separator + @coowners.map { |coowner| coowner.full_name.to_s }.join(", ") ) 
    pdf.move_down 14
    pdf.text("Affiliation: " + @plan.owner.institution.name)
    
    pdf.move_down 14
    
    pdf.text("Last modified: " + @plan.updated_at.strftime("%B %d, %Y"))
    
    pdf.move_down 14
  
    pdf.text("Copyright information: The above plan creator(s) have agreed that others may use ")
    pdf.text("as much of the text of this plan as they would like in their own plans, and customize ")
    pdf.text("it as necessary. You do not need to credit the creators as the source of the ")
    pdf.text("language used, but using any of their plan's text does not imply that the creator(s) ")
    pdf.text("endorse, or have any relationship to, your project or proposal.")

    pdf.stroke do
      pdf.fill_color "808080"
      pdf.stroke_color "808080"
      pdf.rectangle [0, 18], 518, 3
      pdf.fill
    end

    pdf.fill_color "000000"
    pdf.stroke_color "000000"

    pdf.start_new_page

  end

  pdf.font_size(20)
  pdf.text(@plan.name)

  pdf.move_down 10
  pdf.stroke_horizontal_rule
  pdf.move_down 10

  @plan.requirements_template.requirements.order(:position).roots.each_with_index do |req, i|
    # print_responses(pdf, req, (i + 1).to_s) #with ordering
    print_responses(pdf, req, "") #without ordering
  end

  # Generate footer for every page except cover if cover is present
  if @cover == true
    pdf.repeat(lambda { |pg| pg != 1 }) do
      pdf.canvas do
        pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 40],
                         :width  => pdf.bounds.absolute_left + pdf.bounds.absolute_right,
                         :height => 40) do
          pdf.stroke_horizontal_rule
          pdf.move_down(5)
          pdf.text("Created using the DMPTool. Last modified #{@plan.updated_at.strftime("%B %d, %Y")}", :size => 12, :align=>:center)
        end
      end  
    end
  else
    pdf.repeat :all do
      pdf.canvas do
        pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 40],
                         :width  => pdf.bounds.absolute_left + pdf.bounds.absolute_right,
                         :height => 40) do
          pdf.stroke_horizontal_rule
          pdf.move_down(5)
          pdf.text("Created using the DMPTool. Last modified #{@plan.updated_at.strftime("%B %d, %Y")}", :size => 12, :align=>:center)
        end
      end  
    end
  end
end

pdf.render
