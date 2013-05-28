class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.integer :order
      t.integer :parent_requirement
      t.string :text_brief
      t.text :text_full
      t.column :requirement_type, :enum, limit: [:text, :numeric, :date, :enum]
      t.column :obligation, :enum, limit: [:mandatory, :mandatory_applicable, :recommended, :optional]
      t.text :default
      t.integer :requirements_template_id

      t.timestamps
    end
  end
end
