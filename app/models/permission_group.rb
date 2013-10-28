class PermissionGroup < ActiveRecord::Base
	belongs_to :institution
	belongs_to :authorization
end
