class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :requirements_template_id
      t.string :solicitation_identifier
      t.timestamp :submission_deadline
      t.column :visibility, :enum, limit: [:institutional, :public, :shared]

      t.timestamps
    end
  end
end
