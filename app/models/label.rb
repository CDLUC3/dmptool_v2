class Label < ActiveRecord::Base
  belongs_to :requirement, inverse_of: :labels

  validates :requirement, presence: true
end
