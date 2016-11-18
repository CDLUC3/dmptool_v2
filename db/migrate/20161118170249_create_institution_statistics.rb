class CreateInstitutionStatistics < ActiveRecord::Migration
  def change
    create_table :institution_statistics do |t|
      t.string  :run_date
      t.integer :new_users
      t.integer :total_users
      t.integer :new_completed_plans
      t.integer :total_completed_plans

      t.timestamps
    end
    
    add_reference :institution_statistics, :institution, foreign_key: true
    
    add_index :institution_statistics, :run_date
  end
end
