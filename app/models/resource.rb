class Resource < ActiveRecord::Base
  has_many :resource_contexts

  #validates_columns :resource_type
  validates :resource_type, presence: true
  validates :value, presence: true, if: Proc.new{|r| r.resource_type == 'actionable_url' }
  validates :label, presence: true
  

  # validates_columns :value



  scope :guidance, -> { where(resource_type: 'help_text') }
  scope :actionable_url, -> { where(resource_type: 'actionable_url') }
  scope :suggested_response, -> { where(resource_type: 'suggested_response') }
  scope :example_response, -> { where(resource_type: 'example_response') }

  def actionable_url
  	resource_type == "actionable_url"
  end

 

end

