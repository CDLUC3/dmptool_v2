class AdditionalInformation < ActiveRecord::Base
  belongs_to :requirements_template, inverse_of: :additional_informations

  validates :requirements_template, presence: true
end
