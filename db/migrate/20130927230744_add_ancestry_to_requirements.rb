class AddAncestryToRequirements < ActiveRecord::Migration
  def change
  	add_column :requirements, :ancestry, :string
  end
end
