class AddCurrentStatusToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :current_plan_state_id, :integer
  end
end
