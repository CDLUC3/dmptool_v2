class Requirement < ActiveRecord::Base
  include ActiveModel::Validations
  has_ancestry
  has_many :resources
  has_many :responses
  has_many :enumerations, inverse_of: :requirement
  belongs_to :requirements_template

  accepts_nested_attributes_for :enumerations, allow_destroy: true, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }

  validates_columns :requirement_type, :obligation
  validates :text_brief, presence: true
  validates :requirements_template_id, presence: true


  #These don't need to be validated if requirement is not a leaf
  validates :text_full, presence: true, unless: Proc.new { |x| x.is_group? }
  validates :obligation, presence: true, unless: Proc.new { |x| x.is_group? }

  def is_group?
    self.group == true
  end

  # to_do
  # def validate_no_subgroup_within_a_requirement
  #   if self.text_full.present? && self.text_obligation.present?
  #     errors.add( "A Requirement Sub group cannot be added under a Requirement")
  #   end
  # end
end
