class AddRequirementIdColumnToLabels < ActiveRecord::Migration
  def change
    add_column :labels, :requirement_id, :integer
  end
end
