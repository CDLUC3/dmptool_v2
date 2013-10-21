class Enumeration < ActiveRecord::Base
  belongs_to :requirement, inverse_of: :enumerations

  validates :requirement_id, presence: true, numericality: true
end
