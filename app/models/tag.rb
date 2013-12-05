class Tag < ActiveRecord::Base
  belongs_to :requirements_template, inverse_of: :tags

  validates :requirements_template, presence: true
end
