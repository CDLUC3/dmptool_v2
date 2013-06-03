class CreateSamplePlans < ActiveRecord::Migration
  def change
    create_table :sample_plans do |t|
      t.string :url
      t.string :label
      t.integer :requirements_template_id

      t.timestamps
    end
  end
end
