class AdditionalInformation < ActiveRecord::Base
  belongs_to :requirements_template

  validates :requirements_template_id, presence: true, numericality: true
end
