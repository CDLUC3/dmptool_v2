class CreateOverallStatistics < ActiveRecord::Migration
  def change
    create_table :overall_statistics do |t|
      t.string  :month
      
      t.integer :total_users
      t.integer :new_users
      t.integer :unique_users
      
      t.integer :new_institutions
      t.integer :total_institutions
      
      t.integer :new_completed_plans
      t.integer :new_public_plans
      t.integer :total_public_plans
      
      t.integer :most_used_public_template
      t.integer :new_plans_using_public_template
      t.integer :total_plans_using_public_template

      t.string :public_template_of_the_month
      t.string :top_ten_institutions_by_users
      t.string :top_ten_institutions_by_plans

      t.timestamps
    end
  end
end