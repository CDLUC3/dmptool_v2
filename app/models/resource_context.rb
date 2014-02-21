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

  def self.order_by_resource_label
    joins(:resource).order("resources.label ASC")
    #joins(:resource).order(" FIELD(resources.label,'') ASC")
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
  	 where("institution_id IS NOT NULL") 
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
      return "Institution"
    end
    if requirements_template_id != nil && self.requirement_id == nil && self.resource_id != nil && self.institution_id == nil
      return "Template"
    end
    
    if self.requirement_id != nil && self.resource_id != nil && self.institution_id == nil
      return "Requirement"
    end
    if self.requirements_template_id != nil && self.requirement_id == nil && self.resource_id != nil && self.institution_id != nil
      return "Template - Institution"
    end
    if self.requirement_id != nil && self.resource_id != nil && self.institution_id != nil
      return "Requirement - Institution"
    end
    if self.requirements_template == nil && self.requirement_id == nil && self.resource_id != nil && self.institution_id == nil
      return "Global"
    end
    return " "
  end


 

end

