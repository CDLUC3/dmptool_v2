module HtmlToPdf
  TEXT_TYPES = ['b', 'strong', 'i', 'em', 'u', 's', 'sup', 'sub', 'text', 'br', 'a']

  TEXT_STYLES = {'b' => :bold, 'strong' => :bold, 'i' => :italic, 'em' => :italic,
                  'u' => :underline, 's' => :strikethrough, 'sup' => :superscript,
                  'sub' => :subscript }


  # helper method to return styles and text for fairly simple formatted text (can recurse on itself)
  def self.mk_formatted_text(n, styles = [])
    case
      when TEXT_STYLES.keys.include?(n.name)
        n.children.map{|c| mk_formatted_text(c, styles.push(TEXT_STYLES[n.name])) }
      when n.name == 'text'
        {:text => n.text.gsub(/[\r\n\t]/, ''), :styles => styles}
      when n.name == 'br'
        {:text => '\n' }
      when n.name == 'a'
        {:text =>n.text, :link => n['href'], :styles => styles.push(:underline) }
      else
        #raise Exception.new("Unexpected tag: #{n.name}.")
        {:text => n.text,
         :styles => styles}
    end
  end

  def self.mk_formatted_texts(n)
    my_texts = n.map do |c|
      if TEXT_TYPES.include?(c.name)
        mk_formatted_text(c)
      else
        nil
      end
    end
    my_texts.reject(&:nil?).flatten
  end

  # this is the main method which recursively calls itself and takes a
  # a Prawn PDF document to add to,
  # a Nokogiri node (may be root of an html document),
  # and a current state (optional, mostly used for recursive calls)
  # these may be more large-score formats?
  def self.render_html(pdf, n, temp_state={})
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
            if TEXT_TYPES.include?(child.name)
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
end