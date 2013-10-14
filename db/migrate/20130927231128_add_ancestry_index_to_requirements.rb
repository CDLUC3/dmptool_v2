class AddAncestryIndexToRequirements < ActiveRecord::Migration
  def change
		add_index :requirements, :ancestry
  end
end
