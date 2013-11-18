class Institution < ActiveRecord::Base
  acts_as_paranoid

	mount_uploader :logo, LogoUploader

	has_ancestry
	has_many :users
	has_many :resource_templates        
	has_many :requirements_templates

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
    #this query should be used in most cases, rather than the default association
    RequirementsTemplate.where(institution_id: self.subtree_ids)
  end
  
  def resource_templates_deep
    #gets the deep list of all resource templates for this and all sub-institutions under it
    #this query should be used in most cases, rather than the default association
    ResourceTemplate.where(institution_id: self.subtree_ids)
  end
  
  def users_in_role(role_name)
    User.joins({:authorizations => :role}).where("roles.name = ?", role_name).where(institution_id: self.id)
  end
  
end
