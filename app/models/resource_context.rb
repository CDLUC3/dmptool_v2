class ResourceContext < ActiveRecord::Base
  belongs_to :institution
  belongs_to :requirements_template
  belongs_to :requirement
  belongs_to :resource


  scope :institution_set, where("institution_id IS NOT NULL")
  scope :template_set, where("requirements_template_id IS NOT NULL")

end
