class AddColumnsToResponses < ActiveRecord::Migration
  def change
  	add_column :responses, :numeric_value, :integer
  	add_column :responses, :date_value, :date
  	add_column :responses, :enumeration_id, :integer
  end
end
