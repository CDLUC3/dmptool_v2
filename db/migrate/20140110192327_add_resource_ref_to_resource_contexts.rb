class AddResourceRefToResourceContexts < ActiveRecord::Migration
  def change
    add_reference :resource_contexts, :resource, index: true
  end
end
