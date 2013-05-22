class Institution < ActiveRecord::Base

  has_many :users
  has_many :resource_templates

  validates :full_name, presence: true

end
