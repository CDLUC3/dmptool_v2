class AddOrcidIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :orcid_id, :string
  end
end
