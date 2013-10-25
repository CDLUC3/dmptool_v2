class SamplePlan < ActiveRecord::Base
  belongs_to :requirements_template, inverse_of: :sample_plans

  validates :requirements_template, presence: true
end
