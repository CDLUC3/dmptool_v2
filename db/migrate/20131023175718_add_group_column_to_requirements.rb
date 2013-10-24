class AddGroupColumnToRequirements < ActiveRecord::Migration
  def change
    add_column :requirements, :group, :boolean
  end
end
