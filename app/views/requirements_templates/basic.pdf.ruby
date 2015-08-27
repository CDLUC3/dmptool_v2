# -*- mode: ruby -*-
require 'nokogiri'

def print_responses(pdf, requirement, heading)
  pdf.pad(12) do
    pdf.font_size(14)
    pdf.font("Helvetica", :style=>:normal)
    pdf.formatted_text([{:text=> heading, :styles=>[:normal]},
                        {:text=> " #{requirement.text_brief.to_s}", :styles=>[:bold]}])
    unless requirement.text_full.to_s.blank?
      pdf.pad(10) do
        pdf.formatted_text([{:text=> heading, :styles=>[:normal]},
                        {:text=> " #{requirement.text_full.to_s}"}])
      end
    end

    requirement.non_customized_resources.guidance.each do |g|
      html = Nokogiri::HTML(g.text)
      pdf.font("Helvetica", :style=>:normal)
      pdf.pad(10) do
        pdf.indent(12) do
          HtmlToPdf.render_html(pdf, html)
        end
      end
    end
  end
end


pdf = Prawn::Document.new(:bottom_margin=>50, :top_margin=>60, :left_margin=>50) do |pdf|
  @cover = false

  pdf.font_size(16)
  pdf.font("Helvetica", :style=>:normal)
  pdf.text "#{@rt.name}", :align => :center, :style => :bold
  pdf.pad(10) do
    pdf.text "#{@rt.institution.full_name}", :align => :center
  end

  pdf.stroke_horizontal_rule
  pdf.move_down(5)

  @rt.requirements.order(:position).roots.each_with_index do |req, i|
    # print_responses(pdf, req, (i + 1).to_s) #with ordering
    print_responses(pdf, req, "") #without ordering
  end

  # Generate footer for every page except cover if cover is present
  pdf.repeat :all do
    pdf.canvas do
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 40],
                       :width  => pdf.bounds.absolute_left + pdf.bounds.absolute_right,
                       :height => 40) do
        pdf.stroke_horizontal_rule
        pdf.move_down(5)
        pdf.text("Requirements from the DMPTool. Last modified #{@rt.updated_at.strftime("%B %d, %Y")}", :size => 12, :align=>:center)
      end
    end
  end
end

pdf.render
