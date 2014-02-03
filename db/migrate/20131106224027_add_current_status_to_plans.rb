class AddCurrentStatusToPlans < ActiveRecord::Migration
	def self.up
		add_column :plans, :current_plan_state_id, :integer
  end

	def self.down
		add_column :plans, :current_plan_state_id, :integer
	end
end