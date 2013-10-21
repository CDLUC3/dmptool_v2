class AddLogoToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :logo, :string
  end
end
