class AddLockVersionToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :lock_version, :integer, default: 0, null: false
  end
end
