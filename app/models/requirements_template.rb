class RequirementsTemplate < ActiveRecord::Base

  include RequirementsTemplateEmail

  belongs_to :institution
  has_many :requirements, dependent: :destroy
  has_many :tags, inverse_of: :requirements_template, dependent: :destroy
  has_many :additional_informations, inverse_of: :requirements_template, dependent: :destroy
  has_many :sample_plans, inverse_of: :requirements_template, dependent: :destroy
  has_many :resource_contexts, dependent: :destroy
  has_many :plans, dependent: :destroy
  
  has_many :statistics, foreign_key: "requirements_template_id", 
                        class_name: "RequirementsTemplateStatistic"

  accepts_nested_attributes_for :requirements, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
  accepts_nested_attributes_for :tags, allow_destroy: true, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
  accepts_nested_attributes_for :sample_plans, allow_destroy: true, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }
  accepts_nested_attributes_for :additional_informations, allow_destroy: true, reject_if: proc { |attributes| attributes.all? { |key, value| key == '_destroy' || value.blank? } }

  validates_columns :visibility, :review_type
  validates :institution_id, presence: true, numericality: true
  validates :visibility, presence: true
  validates :name, presence: true
  validates :name, uniqueness: { scope: :institution_id, message: "already present for this institution."}

  validates :start_date, date: true, unless: "start_date.nil?"
  validates :end_date, date: true, unless: "end_date.nil?"

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :institutional_visibility, -> { where(visibility: :institutional) }
  scope :public_visibility, -> { where(visibility: :public) }
  scope :current, -> { where("start_date IS NULL OR start_date < ?", Time.new).where("end_date IS NULL OR end_date > ?", Time.new) }
  

  after_initialize :default_values
  # after_initialize :version_number

  # def self.order_by_institution_name
  #   joins(:institution).order('institutions.full_name ASC')
  # end

  def default_values
    self.active ||= false
  end

  # def version_number
  #   if parent_id.nil?
  #     self.version = 1
  #   else
  #     self.version = RequirementsTemplate.where(id: parent_id).version + 1
  #   end
  # end


  def start_date_us_format
    start_date.nil? ? nil : start_date.strftime("%m/%d/%Y") 
  end


  def end_date_us_format
    end_date.nil? ? nil : end_date.strftime("%m/%d/%Y") 
  end

  def created
    created_at.nil? ? nil : created_at.strftime("%m/%d/%Y") 
  end

  def self.letter_range_by_institution(s, e)
    #add as a scope where s=start and e=end letter
    joins(:institution).where("full_name REGEXP ?", "^[#{s}-#{e}]")
  end

  def self.letter_range(s, e)
    where("requirements_templates.name REGEXP ?", "^[#{s}-#{e}]")
  end

  def self.search_terms(terms)
    #searches both institution name and template name
    items = terms.split
    conditions1 = items.map{|item| "full_name LIKE ?" }
    conditions2 = items.map{|item| "name LIKE ?" }
    conditions = "( (#{conditions1.join(' AND ')})" + ' OR ' + "(#{conditions2.join(' AND ')}) )"
    values = items.map{|item| "%#{item}%" }
    joins(:institution).where(conditions, *(values * 2) )
  end

  def self.name_search_terms(terms)
    #searches only template name
    items = terms.split
    conditions = items.map{|item| "name LIKE ?" }
    conditions = "#{conditions.join(' AND ')}"
    values = items.map{|item| "%#{item}%" }
    joins(:institution).where(conditions, *values )
  end

  # returns the first requirement that isn't a container in the list, depth first recursive search
  def first_question
    requirements = self.requirements.roots.order(:position)
    find_question_node(requirements)
  end

  def last_question
    requirements = self.requirements.roots.reorder("position DESC")
    find_last_question_node(requirements)
  end

  #this adds the requirements position if they are not set correctly, but if set, leaves them alone
  def ensure_requirements_position
    reqs = self.requirements.where(position: nil)
    return if reqs.length < 1
    good_reqs = self.requirements.where("position IS NOT NULL").order(:position)
    #consolidate ordered items at first
    good_reqs.each_with_index do |req, i|
      req.update_column(:position, i+1)
    end
    #add order to items missing it at end
    reqs.each_with_index do |req, i|
      req.update_column(:position, i + good_reqs.length + 1)
    end
  end

  def user_can_delete_me?(user)
    ( (user.has_role?(Role::DMP_ADMIN) ||
        (user.has_role?(Role::INSTITUTIONAL_ADMIN) && user.institution.subtree_ids.include?(self.institution_id) ) ||
        (user.has_role?(Role::TEMPLATE_EDITOR) && user.institution.subtree_ids.include?(self.institution_id) ) ) &&
        self.plans.count < 1 )
  end

  private

  #helper method for recursion of first_question
  def find_question_node(reqs)
    reqs.each do |r|
      if r.is_group?
        children = r.children.order(:position)
        return find_question_node(children) unless children.nil? || children.length < 1
      else
        return r
      end
    end
    nil
  end

  #helper method for recursion of last_question
  def find_last_question_node(reqs)
    reqs.each do |r|
      if r.is_group?
        children = r.children.reorder("position DESC")
        return find_question_node(children) unless children.nil? || children.length < 1
      else
        return r
      end
    end
    nil
  end
  public
end