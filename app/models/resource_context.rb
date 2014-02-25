class ResourceContext < ActiveRecord::Base
  belongs_to :institution
  belongs_to :requirements_template
  belongs_to :requirement
  belongs_to :resource


  validates :name, presence: {message: "%{value} must be filled in"}, if: "resource_id.blank?"
  validates :contact_info, presence: {message: "%{value} must be filled in"}, if: "resource_id.blank? && !institution_id.blank?"
  validates :contact_email, format: { with: /.+\@.+\..+/,
                                      message: "%{value} address must be valid" }, if: "resource_id.blank? && !institution_id.blank?"
  validates :review_type, presence: true, if: "resource_id.blank? && !institution_id.blank?"

  
   def self.search_terms(terms)
    items = terms.split
    conditions = " ( " + items.map{|item| "resources.label LIKE ?" }.join(' AND ') + " ) " 
    where(conditions, *items.map{|item| "%#{item}%" })
  end

  def self.order_by_template_name
    joins(:requirements_template).order('requirements_templates.name ASC')
  end

  def self.order_by_name
    order('name ASC')
  end

  def self.order_by_created_at
    order('created_at DESC' )
  end

  def self.order_by_updated_at
    order('updated_at DESC' )
  end

  def self.order_by_resource_label
    joins(:resource).order("resources.label ASC")
  end

  def self.order_by_resource_id
    order('resource_id ASC' )
  end

  def self.order_by_resource_type
    joins(:resource).order('resources.resource_type ASC')
  end

  def self.order_by_institution_name
    joins(:institution).order('institutions.full_name ASC')
  end

  def self.order_by_resource_created_at
    joins(:resource).order('resources.created_at ASC')
  end

  def self.order_by_resource_updated_at
    joins(:resource).order('resources.updated_at ASC')
  end

  def self.no_resource_no_requirement
  	 where(:requirement_id => nil, :resource_id => nil)
  end

  def self.institutional_level
  	 where("resource_contexts.institution_id IS NOT NULL") 
  end

  def self.resource_level
     where("resource_id IS NOT NULL") 
  end

  def self.per_institution(institution)
     where(institution_id: [institution.subtree_ids]) 
  end

  def self.per_template(template)
     where(requirements_template_id: template.id) 
  end

  def self.requirement_level
    where("requirement_id IS NOT NULL")
  end

  def self.template_level
  	 where("requirements_template_id IS NOT NULL")
  end

  def self.resource_not_null
    where("resource_id IS NOT NULL") 
  end

  
  def resource_level
    if requirements_template_id == nil && self.requirement_id == nil && self.resource_id != nil && self.institution_id != nil
      return "Institution" # Stephen's #4, set for all of a viewing institution, every requirement and template
    end
    if requirements_template_id != nil && self.requirement_id == nil && self.resource_id != nil && self.institution_id == nil
      return "Template" # Stephen's #2, set for all views of that template, no matter what viewing institution
    end
    
    if self.requirement_id != nil && self.resource_id != nil && self.institution_id == nil
      return "Requirement" # Stephen's #3, set for all views of that requirement, no matter what viewing institution
    end
    if self.requirements_template_id != nil && self.requirement_id == nil && self.resource_id != nil && self.institution_id != nil
      return "Template - Institution" # Stephen's #5, set for views of an entire template (all requirements) only by a viewing institution
    end
    if self.requirement_id != nil && self.resource_id != nil && self.institution_id != nil
      return "Requirement - Institution" # Stephen's #7, set for views of a requirement by a viewing institution
    end
    if self.requirements_template == nil && self.requirement_id == nil && self.resource_id != nil && self.institution_id == nil
      return "Global" # Stephen's #1 shown for every requirement for all templates, no matter what viewing institution
    end
    if self.resource_id.nil? && self.institution_id != nil && self.requirements_template_id != nil && self.requirement_id.nil?
      return "Container - Institution" # Stephen's case #6, a container for customizing for a template for a viewing institution
    end
    if self.resource_id.nil? && self.institution_id.nil? && self.requirements_template_id != nil && self.requirement_id.nil?
      return "Container - Template" # Marisa's case #8, a container for customizing for a template for all viewing institutions
    end
    return " "
  end


 

end

