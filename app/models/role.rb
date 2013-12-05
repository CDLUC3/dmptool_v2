class Role < ActiveRecord::Base
	has_many :authorizations
	has_many :users, through: :authorizations

	validates :name, presence: true
	
	DMP_ADMIN              = 1
	RESOURCE_EDITOR        = 2
	TEMPLATE_EDITOR        = 3
	INSTITUTIONAL_REVIEWER = 4
	INSTITUTIONAL_ADMIN    = 5
end
