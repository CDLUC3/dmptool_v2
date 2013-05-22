class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.column :role, :enum, limit: [:dmp_owner, :dmp_co_owner, :requirements_editor, :resources_editor, :institutional_reviewer, :institutional_administrator, :dmp_administrator]
      t.integer :group
      t.integer :user_id

      t.timestamps
    end
  end
end
