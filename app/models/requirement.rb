class Requirement < ActiveRecord::Base

  has_ancestry
  has_many :responses
  has_many :enumerations, inverse_of: :requirement
  has_many :labels, inverse_of: :requirement
  has_many :resource_contexts
  belongs_to :requirements_template

  accepts_nested_attributes_for :enumerations, allow_destroy: true, reject_if: proc { |attributes| attributes['value'].blank? }
  accepts_nested_attributes_for :labels, allow_destroy: true, reject_if: proc { |attributes| attributes['desc'].blank? }
  default_scope { order('position ASC') }  # requirements should be ordered by position by default, rather than by the id or date

  validates_columns :requirement_type, :obligation
  validates :text_brief, presence: true
  validates :requirements_template_id, presence: true

  #These don't need to be validated if it is a requirement group.
  validates :text_full, presence: true, unless: Proc.new { |x| x.is_group? }
  validates :obligation, presence: true, unless: Proc.new { |x| x.is_group? }
  validates :requirement_type, presence: true, unless: Proc.new { |x| x.is_group? }

  after_save :add_high_position
  after_destroy :close_gap_in_position

  SELECT_FOR_CONTEXT =  'resources.*, resource_contexts.id AS resource_context_id, resource_contexts.institution_id, ' +
                        'resource_contexts.requirements_template_id, resource_contexts.requirement_id'

  def is_group?
    self.group == true
  end

  before_save :validating_to_set_either_subgroup_or_requirement
  before_save :validating_not_to_add_a_child_under_a_leaf
  validate :has_alteast_one_enumeration, on: :create


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

  def has_alteast_one_enumeration
    if self.requirement_type == :enum && self.enumerations.blank?
      errors[:base] << 'Must add at least one Enumeration value'
    end
  end

  # gets all the resources, of any kind of attachment that are attached to this requirement
  # as viewed by the institution in the parameter
  def resources(viewing_institution_id)
    template_id = self.requirements_template.id
    Resource.joins(:resource_contexts).
        select(SELECT_FOR_CONTEXT).
        where("resource_contexts.resource_id IS NOT NULL").
        where("resource_contexts.institution_id IS NULL OR resource_contexts.institution_id = ?", viewing_institution_id).
        where("resource_contexts.requirements_template_id IS NULL OR resource_contexts.requirements_template_id = ?", template_id ).
        where("resource_contexts.requirement_id IS NULL OR requirement_id = ?", self.id)
  end

  # gets all the resources that are not customized for a specific institution's viewing.  Levels 1, 2, 3
  def non_customized_resources
    template_id = self.requirements_template.id
    Resource.joins(:resource_contexts).
        select(SELECT_FOR_CONTEXT).
        where("resource_contexts.resource_id IS NOT NULL").
        where("resource_contexts.institution_id IS NULL").
        where("resource_contexts.requirements_template_id IS NULL OR resource_contexts.requirements_template_id = ?", template_id ).
        where("resource_contexts.requirement_id IS NULL OR requirement_id = ?", self.id)
  end

  # global resources for this requirement, Stephen's case #1
  def global_resources
    Resource.joins(:resource_contexts).
        select(SELECT_FOR_CONTEXT).
        where("resource_contexts.institution_id IS NULL").
        where("resource_contexts.requirements_template_id IS NULL").
        where("resource_contexts.requirement_id IS NULL").
        where("resource_contexts.resource_id IS NOT NULL")
  end

  # template resources for this template or template and requirement, Stephen's case #2
  def template_resources
    template_id = self.requirements_template.id
    Resource.joins(:resource_contexts).
        select(SELECT_FOR_CONTEXT).
        where("resource_contexts.institution_id IS NULL").
        where("resource_contexts.requirements_template_id = ?", template_id).
        where("resource_contexts.requirement_id IS NULL").
        where("resource_contexts.resource_id IS NOT NULL")
  end

  # requirement resources for this template or template and requirement, Stephen's case #3
  def requirement_resources
    template_id = self.requirements_template.id
    Resource.joins(:resource_contexts).
        select(SELECT_FOR_CONTEXT).
        where("resource_contexts.institution_id IS NULL").
        where("resource_contexts.requirements_template_id = ?", template_id).
        where("resource_contexts.requirement_id = ?", self.id).
        where("resource_contexts.resource_id IS NOT NULL")
  end

  # institution global resources, Stephen's case #4
  def institution_customization_resources(viewing_institution_id)
    Resource.joins(:resource_contexts).
        select(SELECT_FOR_CONTEXT).
        where("resource_contexts.institution_id = ?", viewing_institution_id).
        where("resource_contexts.requirements_template_id IS NULL").
        where("resource_contexts.requirement_id IS NULL").
        where("resource_contexts.resource_id IS NOT NULL")
  end

  # institution resources for this template, Stephen's case #5
  def template_customization_resources(viewing_institution_id)
    template_id = self.requirements_template.id
    Resource.joins(:resource_contexts).
        select(SELECT_FOR_CONTEXT).
        where("resource_contexts.institution_id = ?", viewing_institution_id).
        where("resource_contexts.requirements_template_id = ?", template_id).
        where("resource_contexts.requirement_id IS NULL").
        where("resource_contexts.resource_id IS NOT NULL")
  end

  # institution resources for this template and requirement, Stephen's case #7
  def requirement_customization_resources(viewing_institution_id)
    template_id = self.requirements_template.id
    Resource.joins(:resource_contexts).
        select(SELECT_FOR_CONTEXT).
        where("resource_contexts.institution_id = ?", viewing_institution_id).
        where("resource_contexts.requirements_template_id = ?", template_id).
        where("resource_contexts.requirement_id = ?", self.id).
        where("resource_contexts.resource_id IS NOT NULL")
  end

  #removes this requirement from the position and set its position to nil
  def remove_from_position
    return if self.position.nil?
    renumber_from = self.position
    self.position = nil
    self.update_column(:position, nil)
    Requirement.where(requirements_template_id: self.requirements_template_id).
                where("position > ?", renumber_from).
                update_all("position = position - 1")
  end

  #positions this requirement before the ID of the other requirement in the order
  def position_before(requirement_id)
    items = Requirement.where(requirements_template_id: self.requirements_template_id).where(id: requirement_id).count
    return if items < 1
    remove_from_position
    before_req = Requirement.find(requirement_id)
    from_position = before_req.position
    Requirement.where(requirements_template_id: before_req.requirements_template_id).
        where("position >= ?", from_position).
        update_all("position = position + 1")
    self.update_column(:position, from_position)
  end

  #positions this requirement after the ID of the other requirement in the order
  def position_after(requirement_id)
    items = Requirement.where(requirements_template_id: self.requirements_template_id).where(id: requirement_id).count
    return if items < 1
    remove_from_position
    after_req = Requirement.find(requirement_id)
    from_position = after_req.position

    Requirement.where(requirements_template_id: after_req.requirements_template_id).
        where("position > ?", from_position).
        update_all("position = position + 1")

    self.update_column(:position, from_position + 1)
  end

  #this is used to add a position to a requirement if it is not set, if position is set then it's ignored
  def add_high_position
    return unless self.position.nil?
    return if self.requirements_template_id.nil?
    rt = self.requirements_template
    m = rt.requirements.maximum(:position)
    if m.nil?
      m = 1
    else
      m += 1
    end
    self.update_column(:position, m)
  end

  def close_gap_in_position
    renumber_from = self.position

    Requirement.where(requirements_template_id: self.requirements_template_id).
        where("position > ?", renumber_from).
        update_all("position = position - 1")
  end

  def self.requirements_with_mandatory_obligation(plan_id, requirements_template_id)
    joins(:responses).
    where("requirements.obligation = ?", :mandatory).
    where("requirements.requirements_template_id = ?", requirements_template_id).
    where("responses.plan_id = ?", plan_id)
  end

  def next_requirement_id
    #first child
    unless self.children.order(:position).blank?
      return self.children.order(:position).first.id
    end

    #or next sibling
    siblings = self.siblings.order(:position).where(requirements_template_id: self.requirements_template_id).pluck(:id)
    next_sib = siblings.index(self.id) + 1
    unless next_sib == siblings.length #unless last sibling
      return siblings[next_sib]
    end

    #for parent's siblings
    item = self.parent
    while !item.nil?
      siblings = item.siblings.order(:position).where(requirements_template_id: item.requirements_template_id).pluck(:id)
      next_sib = siblings.index(item.id) + 1
      unless next_sib == siblings.length #unless last sibling
        return siblings[next_sib]
      end
      item = item.parent
    end

    return self.id
  end
end
