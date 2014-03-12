class Response < ActiveRecord::Base

  belongs_to :plan
  belongs_to :requirement

  validates :plan_id, presence: true, numericality: true
  validates :requirement_id, presence: true, numericality: true
  validates :text_value, presence: true, if: :validate_only_if_obligation_mandatory

  #validate :update_with_conflict_validation, on: :update

  def validate_only_if_obligation_mandatory
  	requirement_id = self.requirement_id
  	obligation = Requirement.find(requirement_id).obligation
  	if obligation == :mandatory
  		return true
  	else
  		return false
  	end
  end

  # def update_with_conflict_validation
  #   update
  #   rescue ActiveRecord::StaleObjectError
  #     errors.add :base, "This record changed while you were editing."
  #     false
  #   end
  # end

end
