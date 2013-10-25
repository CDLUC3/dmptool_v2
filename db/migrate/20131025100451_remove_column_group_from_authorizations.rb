class RemoveColumnGroupFromAuthorizations < ActiveRecord::Migration
  def change
  	remove_column :authorizations, :group, :integer
  end
end
