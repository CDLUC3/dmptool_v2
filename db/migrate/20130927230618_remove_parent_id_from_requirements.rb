class RemoveParentIdFromRequirements < ActiveRecord::Migration
  def change
  	remove_column :requirements, :parent_requirement
  end
end
