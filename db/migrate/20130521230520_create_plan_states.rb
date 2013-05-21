class CreatePlanStates < ActiveRecord::Migration
  def change
    create_table :plan_states do |t|
      t.integer :plan_id
      t.column :state, :enum, limit: [:new, :committed, :submitted, :approved, :rejected, :revised, :inactive, :deleted]
      t.integer :user_id

      t.timestamps
    end
  end
end
