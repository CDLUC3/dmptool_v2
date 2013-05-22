class CreatePermissionGroups < ActiveRecord::Migration
  def change
    create_table :permission_groups do |t|
      t.integer :group
      t.integer :institution_id

      t.timestamps
    end
  end
end
