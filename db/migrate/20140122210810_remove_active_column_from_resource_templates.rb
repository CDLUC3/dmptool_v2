class RemoveActiveColumnFromResourceTemplates < ActiveRecord::Migration
  def change
    remove_column :resource_templates, :active, :boolean
  end
end
