class AddPositionToRequirement < ActiveRecord::Migration
  def change
    add_column :requirements, :position, :integer
  end
end
