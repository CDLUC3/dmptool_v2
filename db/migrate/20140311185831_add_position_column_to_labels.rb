class AddPositionColumnToLabels < ActiveRecord::Migration
  def change
    add_column :labels, :position, :integer
  end
end
