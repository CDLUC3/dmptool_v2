class ChangeColumnTypeInAuthorizations < ActiveRecord::Migration
  def change
  	change_column :authorizations, :role, :integer
  end
end
