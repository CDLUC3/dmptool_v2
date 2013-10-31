class AddDeletedAtToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :deleted_at, :datetime
  end
end
