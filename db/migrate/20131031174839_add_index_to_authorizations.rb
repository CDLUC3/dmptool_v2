class AddIndexToAuthorizations < ActiveRecord::Migration
	def self.up
		add_index :authorizations, [:user_id, :role_id], :unique => true
  end

	def self.down
		remove_index :authorizations, [:user_id, :role_id], :unique => true
  end
end
