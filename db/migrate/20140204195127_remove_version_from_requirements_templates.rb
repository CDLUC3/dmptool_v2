class RemoveVersionFromRequirementsTemplates < ActiveRecord::Migration
  def change
    remove_column :requirements_templates, :version, :integer
  end
end
