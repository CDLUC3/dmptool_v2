class Enumeration < ActiveRecord::Base
  belongs_to :requirement, inverse_of: :enumerations

  validates :requirement, presence: true
end
