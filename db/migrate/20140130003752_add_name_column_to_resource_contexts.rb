class AddNameColumnToResourceContexts < ActiveRecord::Migration
  def change
    add_column :resource_contexts, :name, :string
  end
end
