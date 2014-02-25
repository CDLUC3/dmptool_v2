class UniqueResourceContexts < ActiveRecord::Migration
  def change
    add_index :resource_contexts, [:institution_id, :requirements_template_id, :requirement_id, :resource_id], :unique => true, :name => 'unique_context_index'
  end
end
