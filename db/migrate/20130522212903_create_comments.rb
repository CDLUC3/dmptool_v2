class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.column :visibility, :enum, limit: [:owner, :reviewer]
      t.integer :plan_id
      t.text :value

      t.timestamps
    end
  end
end
