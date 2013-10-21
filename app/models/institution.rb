class Institution < ActiveRecord::Base
mount_uploader :logo, LogoUploader
  has_many :users
  has_many :resource_templates
  has_many :requirements_templates

  validates :full_name, presence: true
	# validates :logo, presence: true, file_size: { :maximum => 0.5.megabytes.to_i }
end
