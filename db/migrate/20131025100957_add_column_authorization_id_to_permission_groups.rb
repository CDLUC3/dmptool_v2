class AddColumnAuthorizationIdToPermissionGroups < ActiveRecord::Migration
  def change
    add_column :permission_groups, :authorization_id, :integer
  end
end
