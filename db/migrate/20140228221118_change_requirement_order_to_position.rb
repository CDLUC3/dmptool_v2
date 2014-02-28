class ChangeRequirementOrderToPosition < ActiveRecord::Migration
  def change
    rename_column :requirements, :order, :position
  end
end
