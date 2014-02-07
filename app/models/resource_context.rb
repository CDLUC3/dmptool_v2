class ResourceContext < ActiveRecord::Base
  belongs_to :institution
  belongs_to :requirements_template
  belongs_to :requirement
  belongs_to :resource

  validates :name, presence: {message: "%{value} must be filled in"}, if: "resource_id.blank?"
  validates :contact_info, presence: {message: "%{value} must be filled in"}, if: "resource_id.blank?"
  validates :contact_email, format: { with: /.+\@.+\..+/,
                                      message: "%{value} address must be valid" }, if: "resource_id.blank?"
  validates :review_type, presence: true, if: "resource_id.blank?"

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


  def self.template_level
  	 where("requirements_template_id IS NOT NULL")
  end

  def self.resource_not_null
    where("resource_id IS NOT NULL") 
  end

end

