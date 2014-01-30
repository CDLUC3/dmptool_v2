class AddContactInfoColumnToResourceContexts < ActiveRecord::Migration
  def change
    add_column :resource_contexts, :contact_info, :string
  end
end
