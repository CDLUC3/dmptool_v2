class AddColumnsIntitutionalContactToResourceTemplate < ActiveRecord::Migration
  def change
  	add_column :resource_templates, :contact_info, :string
  	add_column :resource_templates, :contact_email, :string
  end
end
