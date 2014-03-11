class Response < ActiveRecord::Base

  belongs_to :plan
  belongs_to :requirement

  validates :plan_id, presence: true, numericality: true
  validates :requirement_id, presence: true, numericality: true
  validates :value, presence: true, if: :validate_only_if_obligation_mandatory

  def validate_only_if_obligation_mandatory
  	requirement_id = self.requirement_id
  	obligation = Requirement.find(requirement_id).obligation
  	if obligation == :mandatory
  		return true
  	else
  		return false
  	end
  end
end
