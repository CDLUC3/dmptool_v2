class AddDefaultValueColumnToEnumerations < ActiveRecord::Migration
  def change
  	add_column :enumerations, :default, :boolean
  end
end
