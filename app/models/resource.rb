class Resource < ActiveRecord::Base
  has_many :resource_contexts

  validates_columns :resource_type
  validates :resource_type, presence: true
  validates :value, presence: true
  validates :label, presence: true

  scope :guidance, -> { where(resource_type: 'expository_guidance') }
end
