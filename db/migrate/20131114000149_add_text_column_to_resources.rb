class AddTextColumnToResources < ActiveRecord::Migration
  def change
  	add_column :resources, :text, :text
  end
end
