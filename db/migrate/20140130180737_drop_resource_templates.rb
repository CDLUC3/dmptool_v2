class DropResourceTemplates < ActiveRecord::Migration
  def change
    drop_table "resource_templates"
  end

  # def down
  #   create_table :resource_templates , force: true do |t|
  #     t.integer :requirements_template_id
  #     t.string :name
  #     t.text   :review_type
  #     t.string :widget_url
  #     t.datetime :created_at
  #     t.datetime :updated_at
  #     t.string :contact_info
  #     t.string :contact_email
  #     t.timestamps        
  #   end
    
 
end

