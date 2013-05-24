class Institution < ActiveRecord::Base

  has_many :users
  has_many :resource_templates
  has_many :requirements_templates

  validates :full_name, presence: true

end
