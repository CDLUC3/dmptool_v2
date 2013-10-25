class AddAncestryColumnToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :ancestry, :string
		add_index :institutions, :ancestry
  end
end
