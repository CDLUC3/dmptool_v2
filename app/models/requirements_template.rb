class RequirementsTemplate < ActiveRecord::Base

  belongs_to :institution
  has_many :resource_templates
  has_many :requirements
  has_many :tags
  has_many :additional_informations, inverse_of: :requirements_template
  has_many :sample_plans, inverse_of: :requirements_template

  accepts_nested_attributes_for :resource_templates, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
  accepts_nested_attributes_for :requirements, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
  accepts_nested_attributes_for :tags, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
  accepts_nested_attributes_for :sample_plans, allow_destroy: true, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
  accepts_nested_attributes_for :additional_informations, allow_destroy: true, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }

  validates_columns :visibility, :review_type
  validates :institution_id, presence: true, numericality: true
  validates :visibility, presence: true
  validates :version, presence: true, numericality: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :institutional_visibility, -> { where(visibility: :institutional) }
  scope :public_visibility, -> { where(visibility: :public) }

  after_initialize :default_values
  after_initialize :version_number

  def default_values
    self.active ||= false
  end

  def version_number
    if parent_id.nil?
      self.version = 1
    else
      self.version = RequirementsTemplate.where(id: parent_id).version + 1
    end
  end
end