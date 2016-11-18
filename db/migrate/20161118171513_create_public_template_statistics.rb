class CreatePublicTemplateStatistics < ActiveRecord::Migration
  def change
    create_table :public_template_statistics do |t|
      t.string  :run_date
      t.integer :new_plans
      t.integer :total_plans
      
      t.timestamps
    end
    
    add_reference :public_template_statistics, :requirements_template, foreign_key: true
                      
    add_index :public_template_statistics, :run_date
  end
end
