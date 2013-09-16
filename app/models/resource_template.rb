class ResourceTemplate < ActiveRecord::Base

	belongs_to :institution
	belongs_to :requirements_template
	has_many :resources

  validates_columns :review_type
	validates :name, presence: true
	validates :institution_id, presence: true, numericality: true

	scope :active, -> { where(active: true) }
	scope :inactive, -> { where(active: false) }

	after_initialize  :default_values

	def default_values
		self.active ||= false
	end
end
