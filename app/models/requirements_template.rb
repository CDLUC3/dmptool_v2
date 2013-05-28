class RequirementsTemplate < ActiveRecord::Base

  belongs_to :institution
  has_many :resource_templates
  has_many :requirements
  has_many :tags
  has_many :additional_informations

  validates_columns :visibility
  validates :institution_id, presence: true, numericality: true
  validates :visibility, presence: true
  validates :version, presence: true, numericality: true
  validates :name, presence: true

  after_initialize :version_number

  def version_number
    if parent_id.nil?
      self.version = 1
    else
      self.version = RequirementsTemplate.where(id: parent_id).version + 1
    end
  end
end
