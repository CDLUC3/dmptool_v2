class RemoveGroupColumnFromLabels < ActiveRecord::Migration
  def up
    remove_column :labels, :group
  end
  def down
    add_column :label, :group, :string
  end
end
