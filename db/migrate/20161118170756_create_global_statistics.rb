class CreateGlobalStatistics < ActiveRecord::Migration
  def change
    create_table :global_statistics do |t|
      t.string  :run_date
      t.string  :effective_month
      t.integer :new_users
      t.integer :total_users
      t.integer :new_completed_plans
      t.integer :total_completed_plans

      t.integer :new_public_plans
      t.integer :total_public_plans
      t.integer :new_institutions
      t.integer :total_institutions
      
      t.timestamps
    end
    
    add_index :global_statistics, :run_date
  end
end
