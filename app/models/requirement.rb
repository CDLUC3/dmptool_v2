class Requirement < ActiveRecord::Base

  has_ancestry
  has_many :resources
  has_many :responses
  has_many :enumerations, inverse_of: :requirement
  has_many :resource_contexts
  belongs_to :requirements_template

  accepts_nested_attributes_for :enumerations, allow_destroy: true, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }

  validates_columns :requirement_type, :obligation
  validates :text_brief, presence: true
  validates :requirements_template_id, presence: true

  #These don't need to be validated if it is a requirement group.
  validates :text_full, presence: true, unless: Proc.new { |x| x.is_group? }
  validates :obligation, presence: true, unless: Proc.new { |x| x.is_group? }
  validates :requirement_type, presence: true, unless: Proc.new { |x| x.is_group? }

  def is_group?
    self.group == true
  end

  before_save :validating_to_set_either_subgroup_or_requirement
  before_save :validating_not_to_add_a_child_under_a_leaf

  def validating_to_set_either_subgroup_or_requirement
    parent_id = self.parent_id
    return true if parent_id.nil?
    parent = Requirement.find(parent_id)
    has_children = parent.has_children?
    return true if has_children.nil?
    child = parent.children.first
      if (child.group? == true && self.group? == false)
        errors[:base] <<  "Cannot add a Single Requirement since a Sub Group already exists."
        return false
      elsif (child.group? == false && self.group? == true)
        errors[:base] <<  "Cannot add a Sub Group since a Single Requirement already exists."
        return false
      else
        return true
      end
  end

  def validating_not_to_add_a_child_under_a_leaf
    parent_id = self.parent_id
    return true if parent_id.nil?
    parent = Requirement.find(parent_id)
    if parent.group? == false
      errors[:base] <<  "Cannot add any Requirement or a Sub Group under a Single Requirement."
      return false
    else
      return true
    end
  end

end
