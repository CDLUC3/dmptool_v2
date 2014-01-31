class RemoveResourceTemplateIdFromResourceContexts < ActiveRecord::Migration
  def change
    remove_column :resource_contexts, :resource_template_id, :integer
  end
end
