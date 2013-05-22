class Response < ActiveRecord::Base

  belongs_to :plan
  belongs_to :requirement
  belongs_to :label

  validates :plan_id, presence: true, numericality: true
  validates :requirement_id, presence: true, numericality: true
  validates :value, presence: true

end
