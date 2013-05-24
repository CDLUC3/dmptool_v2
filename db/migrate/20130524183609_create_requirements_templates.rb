class CreateRequirementsTemplates < ActiveRecord::Migration
  def change
    create_table :requirements_templates do |t|
      t.integer :institution_id
      t.string :name
      t.boolean :active
      t.timestamp :start_date
      t.timestamp :end_date
      t.column :visibility, :enum, limit: [:public, :institutional]
      t.integer :version
      t.integer :parent_id
      t.boolean :mandatory_review

      t.timestamps
    end
  end
end
