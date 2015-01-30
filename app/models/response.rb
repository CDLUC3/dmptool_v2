class Response < ActiveRecord::Base

  attr_accessor :current_user_id

  belongs_to :plan
  belongs_to :requirement
  belongs_to :enumeration

  validates :plan_id, presence: true, numericality: true
  validates :requirement_id, presence: true, numericality: true
  
  after_create :check_revised
  after_update :check_revised

  before_destroy :update_plan_modified_date

  validates :text_value, presence: true, if: :requirement_type_is_text
  validates :enumeration_id, presence: true, if: :requirement_type_is_enum
  validate :mandatory_text_or_enum_present  


  def update_plan_modified_date
    plan = self.plan
    plan.touch 
  end


  def mandatory_text_or_enum_present
    requirement_id = self.requirement_id
    obligation = Requirement.find(requirement_id).obligation
    requirement_type = Requirement.find(requirement_id).requirement_type
    if obligation == :mandatory
      if ( ( (text_value.nil?) && (requirement_type == :text) ) || ((enumeration_id.nil?) && (requirement_type == :enum) ) )
        errors.add(:base, "This response is mandatory.")
      end
    end
  end


  def requirement_type_is_text
    requirement_id = self.requirement_id
    requirement_type = Requirement.find(requirement_id).requirement_type 
    if requirement_type == :text
      return true
    else
      return false
    end
  end

  def requirement_type_is_enum
    requirement_id = self.requirement_id
    requirement_type = Requirement.find(requirement_id).requirement_type
    if requirement_type == :enum
      return true
    else
      return false
    end
  end

  # def presence_of_text_or_enumeration_id
  #   requirement_id = self.requirement_id
  #   obligation = Requirement.find(requirement_id).obligation
  #   requirement_type = Requirement.find(requirement_id).requirement_type
  #   if obligation == :mandatory
  #     if ( (text_value.nil? && requirement_type == :text) || 
  #           (enumeration_id.nil? && requirement_type == :enum) )
  #       errors.add(:base, 'This response is mandatory.')
  #       return true
  #     else
  #       return false
  #     end
  #   else
  #     if ( (text_value.nil? && requirement_type == :text) || 
  #           (enumeration_id.nil? && requirement_type == :enum) )
  #       return true
  #     else
  #       return false
  #     end
  #   end
  # end




  # def validate_only_if_obligation_mandatory
  # 	requirement_id = self.requirement_id
  # 	obligation = Requirement.find(requirement_id).obligation
  #   requirement_type = Requirement.find(requirement_id).requirement_type
  # 	if obligation == :mandatory && requirement_type == :text
  # 		return true
  # 	else
  # 		return false
  # 	end
  # end

  def update_with_conflict_validation(*args)
    update(*args)
  rescue ActiveRecord::StaleObjectError
      flash[:error] = "This record changed while you were editing."
      false
  end

  def check_revised
    if self.changed?
      return if plan.current_plan_state_id.nil?
      plan = Plan.find(self.plan_id)
      plan_state_id = plan.current_plan_state_id
      state = PlanState.find(plan_state_id).state
      if (state  == :committed) || (state == :approved) || (state == :rejected) || (state == :reviewed)
        ps = PlanState.new({plan_id: plan.id, state: 'revised', user_id: self.current_user_id.to_i })
        ps.save
      end
    end
  end

end
