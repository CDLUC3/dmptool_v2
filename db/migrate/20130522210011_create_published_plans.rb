class CreatePublishedPlans < ActiveRecord::Migration
  def change
    create_table :published_plans do |t|
      t.integer :plan_id
      t.string :file_name
      t.column :visibility, :enum, limit: [:institutional, :public, :public_browsable]

      t.timestamps
    end
  end
end
