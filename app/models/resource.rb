class Resource < ActiveRecord::Base
  has_many :resource_contexts

  validates_columns :resource_type
  validates :resource_type, presence: true
  validates :value, presence: true, if: :actionable_url
  validates :label, presence: true

  validates_columns :value


  scope :guidance, -> { where(resource_type: 'expository_guidance') }

  def actionable_url
  	resource_type == "actionable_url"
  end


end

