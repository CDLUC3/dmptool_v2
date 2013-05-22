class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :plan_id
      t.integer :requirement_id
      t.integer :label_id
      t.text :value

      t.timestamps
    end
  end
end
