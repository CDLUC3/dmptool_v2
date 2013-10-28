class Institution < ActiveRecord::Base
  acts_as_paranoid

	mount_uploader :logo, LogoUploader
		has_ancestry
  	has_many :users
  	has_many :resource_templates
  	has_many :requirements_templates
		has_many :permission_groups
		has_many :authorizations, through: :permission_groups

  	validates :full_name, presence: true
end
