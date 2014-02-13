require 'prawn'

class PrawnTemplateHandler
  def call(template)
    require_engine
    """
pdf = Prawn::Document.new do |pdf|
  #{template.source}
end
pdf.render
"""
  end
  
  protected
  
  def require_engine
    @required ||= begin
                    require "prawn"
                    true
                  end
  end
end
