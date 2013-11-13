class DropPermissionGroups < ActiveRecord::Migration
  def up
    drop_table "permission_groups"
  end
  
  def down
    create_table "permission_groups", force: true do |t|
      t.integer  "group"
      t.integer  "institution_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "authorization_id"
    end
  end
end
