class Label < ActiveRecord::Base
  belongs_to :requirement, inverse_of: :enumerations

  validates :requirement, presence: true
  validates :desc, presence: true
end
