class ResourceContext < ActiveRecord::Base
  belongs_to :institution
  belongs_to :requirements_template
  belongs_to :requirement
  belongs_to :resource


  validates :name, presence: {message: "%{value} must be filled in"}, if: "resource_id.blank?"
  validates :review_type, presence: true, if: "resource_id.blank? && !institution_id.blank?"
  validates :institution_id, uniqueness: { scope: [:institution_id, :requirements_template_id, :requirement_id, :resource_id],
            message: "You are attempting to insert a duplicate of a customization that already exists." }

  validates :contact_email, format: { with: /.+\@.+\..+/,
            message: "%{value} address must be valid" }, if: "resource_id.blank? && !institution_id.blank?"


  #these are the context levels, their names, descriptions and which items they must have set of
  # institution_id, requirements_template_id, requirement_id, resource_id
  CONTEXT_LEVELS = {
      1 => {name: 'Global',
            inst: false,    req_temp: false,    req: false,     res: true},
            # Stephen's #1 shown for every requirement for all templates, no matter what viewing institution
      2 => {name: 'Template',
            inst: false,    req_temp: true,     req: false,     res: true},
            # Stephen's #2, set for all views of that template, no matter what viewing institution
      3 => {name: 'Requirement',
            inst: false,    req_temp: true,     req: true,      res: true},
            # Stephen's #3, set for all views of that requirement, no matter what viewing institution
      4 => {name: 'Institution',
            inst: true,     req_temp: false,    req: false,     res: true},
            # Stephen's #4, set for all of a viewing institution, every requirement and template
      5 => {name: 'Template - Institution',
            inst: true,     req_temp: true,     req: false,     res: true},
            # Stephen's #5, set for views of an entire template (all requirements) only by a viewing institution
      6 => {name: 'Container - Institution',
            inst: true,     req_temp: true,     req: false,     res: false},
            # Stephen's #6, a container for customizing for a template for a viewing institution
      7 => {name: 'Requirement - Institution',
            inst: true,     req_temp: true,     req: true,      res: true},
            # Stephen's #7, set for views of a requirement by a viewing institution
      8 => {name: 'Container - Template',
            inst: false,    req_temp: true,     req: false,     res: false}
            # Marisa's  #8, a container for customizing for a template for all viewing institutions
  }

  CONTEXT_NAMES_TO_NUMBERS = Hash[ CONTEXT_LEVELS.map{|k,v| [v[:name], k]}]

  
  def self.search_terms(terms)
    items = terms.split
    conditions = " ( " + items.map{|item| "resources.label LIKE ?" }.join(' AND ') + " ) " 
    where(conditions, *items.map{|item| "%#{item}%" })
  end

  def self.help_text_and_url_resources
    joins(:resource).where("resources.resource_type IN (?)", ["actionable_url","help_text"])
  end

  def self.help_text
    joins(:resource).where("resources.resource_type = ?", "help_text")
  end

  def self.actionable_url
    joins(:resource).where("resources.resource_type = ?", "actionable_url")
  end

  def self.suggested_response
    joins(:resource).where("resources.resource_type = ?", "suggested_response")
  end

  def self.example_response
    joins(:resource).where("resources.resource_type = ?", "example_response")
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
    includes(:institution).order('institutions.full_name ASC')
  end

  def self.order_by_resource_created_at
    joins(:resource).order('resources.created_at DESC')
  end

  def self.order_by_resource_updated_at
    joins(:resource).order('resources.updated_at DESC')
  end

  def self.no_resource_no_requirement
  	 where(:requirement_id => nil, :resource_id => nil)
  end

  def self.no_requirement
    where(requirement_id: nil) 
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

  

  

  #see context level variables at top for information
  def resource_level
    CONTEXT_LEVELS.each do |k,v|
      if  v[:inst] != institution_id.nil? &&
          v[:req_temp] != requirements_template_id.nil? &&
          v[:req] != requirement_id.nil? &&
          v[:res] != resource_id.nil?
        return v[:name]
      end
    end
    return " "
  end

  def self.context_name_to_number(level_name)
    keys = CONTEXT_NAMES_TO_NUMBERS.keys
    raise "bad level name" unless keys.include?(level_name)
    CONTEXT_NAMES_TO_NUMBERS[level_name]
  end

  def self.context_info(level_number)
    raise "bad level number" unless CONTEXT_LEVELS.has_key(level_number)
    CONTEXT_LEVELS[level_number]
  end
end

