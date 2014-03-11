class AddPositionColumnToEnumerations < ActiveRecord::Migration
  def change
    add_column :enumerations, :position, :integer
  end
end
