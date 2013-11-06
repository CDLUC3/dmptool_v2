class Institution < ActiveRecord::Base
  acts_as_paranoid

	mount_uploader :logo, LogoUploader

	has_ancestry
	has_many :users
	has_many :resource_templates        
	has_many :requirements_templates
	has_many :permission_groups
	has_many :authorizations, through: :permission_groups

	validates :full_name, presence: true
  
  def plans_by_state(state)
    #get all plans this institution and sub-institutions has in the state specified
    Plan.joins(:plan_states, :requirements_template).
          where(:requirements_templates => { :institution_id => self.subtree_ids }).
          where(:plan_states => { :state => state})
  end
  	
  def unique_plan_states
    #returns a list of the unique plan states that this institution and sub-institutions has
    PlanState.select('state').joins({:plan => :requirements_template}).
          where(:requirements_templates => { :institution_id => self.subtree_ids }).distinct.
          map{|s| s.state.to_s}.sort
  end
  
  def requirements_templates_deep
    #gets the deep list of all requirements templates for this and all sub-institutions under it
    RequirementsTemplate.where(:requirements_templates => { :institution_id => self.subtree_ids})
  end
  
end
