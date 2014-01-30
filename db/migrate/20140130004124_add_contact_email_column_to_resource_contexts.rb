class AddContactEmailColumnToResourceContexts < ActiveRecord::Migration
  def change
    add_column :resource_contexts, :contact_email, :string
  end
end
