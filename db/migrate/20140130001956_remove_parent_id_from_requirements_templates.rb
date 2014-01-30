class RemoveParentIdFromRequirementsTemplates < ActiveRecord::Migration
  def change
    remove_column :requirements_templates, :parent_id, :integer
  end
end
