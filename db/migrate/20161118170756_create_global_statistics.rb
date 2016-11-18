class CreateGlobalStatistics < ActiveRecord::Migration
  def change
    create_table :global_statistics do |t|
      t.string  :run_date
      t.integer :new_users
      t.integer :total_users
      t.integer :new_completed_plans
      t.integer :total_completed_plans

      t.integer :new_public_plans
      t.integer :total_public_plans
      t.integer :new_institutions
      t.integer :total_institutions
      
      t.integer :template_of_the_month
      
      t.string :top_ten_institutions_by_users
      t.string :top_ten_institutions_by_plans
      
      t.timestamps
    end
    
    add_index :global_statistics, :run_date
    add_index :global_statistics, :template_of_the_month
  end
end
