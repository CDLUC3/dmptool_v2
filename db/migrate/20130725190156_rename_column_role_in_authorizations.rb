class RenameColumnRoleInAuthorizations < ActiveRecord::Migration
  def change
  	rename_column :authorizations, :role, :role_id
  end
end
