class ResourceTemplate < ActiveRecord::Base
	belongs_to :institution
	belongs_to :requirements_template
	has_many :resource_contexts

  validates_columns :review_type
	validates :name, presence: true
	validates :institution_id, presence: true, numericality: true
	validates :requirements_template_id, presence:true, numericality: true
end
