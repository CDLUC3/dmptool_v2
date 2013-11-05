class Institution < ActiveRecord::Base
  acts_as_paranoid

	mount_uploader :logo, LogoUploader

	has_ancestry
	has_many :users
	has_many :resource_templates
	has_many :requirements_templates
	has_many :permission_groups
	has_many :authorizations, through: :permission_groups
	
  has_many  :private_requirements_templates, -> { where requirements_templates: { visibility: 'institutional'} },
            source: :requirements_template, class_name: 'RequirementsTemplate'
	
	has_many  :public_requirements_templates, -> { where requirements_templates: { visibility: 'public'} },
            source: :requirements_template, class_name: 'RequirementsTemplate'

	validates :full_name, presence: true
  
  def plans_by_state(state)
    #get all plans this user has in the state specified
    Plan.joins(:plan_states, :requirements_template).
          where(:requirements_templates => { :institution_id => self.id }).
          where(:plan_states => { :state => state})
  end
  	
  def unique_plan_states
    #returns a list of the unique plan states that this institution has
    PlanState.select('state').joins({:plan => :requirements_template}).
          where(:requirements_templates => { :institution_id => self.id }).distinct.
          map{|s| s.state.to_s}.sort
  end
end
