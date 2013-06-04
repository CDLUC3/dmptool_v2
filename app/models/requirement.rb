class Requirement < ActiveRecord::Base

  has_many :enumerations
  has_many :resources
  has_many :responses
  belongs_to :requirements_template

  @tree_parent ||= Requirement.where(parent_requirement: self).order(order: :desc)

  validates_columns :requirement_type, :obligation
  validates :text_brief, presence: true
  validates :requirements_template_id, presence: true, numericality: true

  # These don't need to be validates if requirement is not a leaf
  validates :text_full, presence: true, unless: @tree_parent
  validates :obligation, presence: true, unless: @tree_parent
  validates :order, presence: true, unless: @tree_parent

  before_validation :get_order

  def get_order
    @requirements = @tree_parent

    # Order is 1 if there's not preceding requirement. Otherwise increment.
    self.order =(@requirements ? @requirements.first.order + 1: 1)
  end
end
