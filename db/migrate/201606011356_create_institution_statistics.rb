class CreateInstitutionStatistics < ActiveRecord::Migration
  def change
    create_table :institution_statistics do |t|
      t.string  :month
      t.integer :all_users
      t.integer :users_created
      t.integer :all_plans
      t.integer :test_plans
      t.integer :private_plans
      t.integer :public_plans
      t.integer :plans_created
      t.integer :plans_reviewed
      t.integer :all_templates
      t.integer :templates_used
      t.integer :unique_templates_used
      t.integer :templates_created

      t.integer :institution_id

      t.timestamps
    end
  end
end