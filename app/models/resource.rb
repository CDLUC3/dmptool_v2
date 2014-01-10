class Resource < ActiveRecord::Base

  belongs_to :requirement
  belongs_to :resource_template
  has_many :resource_contexts

  validates_columns :resource_type
  validates :resource_type, presence: true
  validates :value, presence: true
  validates :label, presence: true
  validates :requirement_id, presence: true, numericality: true
  validates :resource_template_id, presence: true, numericality: true
  
  scope :guidance, -> { where(resource_type: 'expository_guidance') }

end
