pdf = Prawn::Document.new do |pdf|
  pdf.font_size(20)
  pdf.text(@plan.name)
end
pdf.render
