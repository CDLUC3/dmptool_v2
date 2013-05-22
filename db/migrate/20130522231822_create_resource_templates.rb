class CreateResourceTemplates < ActiveRecord::Migration
  def change
    create_table :resource_templates do |t|
      t.integer :institution_id
      t.integer :requirements_template_id
      t.string :name
      t.boolean :active, default: false
      t.boolean :mandatory_review
      t.string :widget_url

      t.timestamps
    end
  end
end
