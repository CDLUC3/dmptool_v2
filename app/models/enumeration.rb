class Enumeration < ActiveRecord::Base
  belongs_to :requirement

  validates :requirement_id, presence: true, numericality: true
end
