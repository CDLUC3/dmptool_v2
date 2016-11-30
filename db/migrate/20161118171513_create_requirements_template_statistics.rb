class CreateRequirementsTemplateStatistics < ActiveRecord::Migration
  def change
    create_table :requirements_template_statistics do |t|
      t.string  :run_date
      t.integer :new_plans
      t.integer :total_plans
      
      t.timestamps
    end
    
    add_reference :requirements_template_statistics, :requirements_template, foreign_key: true
                      
    add_index :requirements_template_statistics, :run_date
  end
end
