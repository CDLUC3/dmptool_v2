class Institution < ActiveRecord::Base
  acts_as_paranoid

	mount_uploader :logo, LogoUploader

	has_ancestry
	has_many :users
	has_many :resource_templates
	has_many :requirements_templates
  has_many :resource_contexts
  
  has_many :statistics, foreign_key: "institution_id", 
                        class_name: "InstitutionStatistic"

	validates :full_name, presence: true

  def plans_by_state(state)
    #get all plans this institution and sub-institutions has in the state specified
    Plan.joins(:current_state, :requirements_template).
          where(:requirements_templates => { :institution_id => self.subtree_ids }).
          where(:plan_states => { :state => state})
  end

  def unique_plan_states
    #returns a list of the unique plan states that this institution and sub-institutions has
    Plan.joins(:current_state, :requirements_template).
        where(:requirements_templates => { :institution_id => self.subtree_ids }).
        select('plan_states.state').distinct.pluck(:state)
  end

  def requirements_templates_deep
    #gets the deep list of all requirements templates for this and all sub-institutions under it
    RequirementsTemplate.where(institution_id: self.subtree_ids)
  end

  def resource_templates_deep
    #gets the deep list of all resource templates for this and all sub-institutions under it
    ResourceTemplate.where(institution_id: self.subtree_ids)
  end
  
  def users_deep
    #gets the list of all users associated with this institution and sub-institutions
    User.where(institution_id: self.subtree_ids)
  end

  def non_admin_users
    self.users.includes(:authorizations).where(authorizations: {role_id: nil})
  end

  def users_in_role(role_name)
    User.joins({:authorizations => :role}).where("roles.name = ?", role_name).where(institution_id: [self.subtree_ids])
  end

  def users_in_and_above_inst_in_role(role_number)
    insts = [self.id] + self.ancestor_ids
    User.joins({:authorizations => :role}).where("roles.id = ?", role_number).where(institution_id: insts)
  end

  def users_deep_in_any_role
    #users that have any kind of role
    @user_ids = Authorization.pluck(:user_id) 
    User.where(id: @user_ids, institution_id: self.subtree_ids)
  end

  def users_in_role_any_institution(role_name)
    User.joins({:authorizations => :role}).where("roles.name = ?", role_name)
  end

  def users_deep_in_any_role_any_institution
    @user_ids = Authorization.pluck(:user_id) 
    User.where(id: @user_ids)
  end

  def name #alias name to full name for ease of use, but don't change to alias command because it breaks activerecord
    full_name
  end

  def is_shibboleth?
    self.shib_entity_id.to_s != ''
  end

  def is_customized?
    self.resource_contexts.where("requirements_template_id IS NOT NULL").where("resource_id IS NULL").count > 0
  end

  def self.letter_range(s, e)
    #add as a scope where s=start and e=end letter
    where("full_name REGEXP ?", "^[#{s}-#{e}]")
  end

  def self.search_terms(terms)
    items = terms.split
    conditions = " ( " + items.map{|item| "full_name LIKE ?" }.join(' AND ') + " ) " 
    where(conditions, *items.map{|item| "%#{item}%" })
  end

  def self.unique_plans
    joins(:requirements_templates, :plans).
    where(:requirements_templates => { :institution_id => self.subtree_ids }).
    group(:plan_id)
  end

end
