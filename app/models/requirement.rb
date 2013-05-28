class Requirement < ActiveRecord::Base
  
  has_many :enumerations
  has_many :resources
  has_many :responses
  belongs_to :requirements_template

  validates_columns :requirement_type, :obligation
  validates :text_brief, presence: true
  validates :requirements_template_id, presence: true, numericality: true
  
  #validates :validations
  # def validations
  #   @is_parent ||= Requirement.where(parent_id: self.id).count == 0

  #   unless @is_parent
  #     #Is leaf

  #   end
  # end
end
