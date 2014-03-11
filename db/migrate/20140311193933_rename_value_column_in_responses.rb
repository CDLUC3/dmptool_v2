class RenameValueColumnInResponses < ActiveRecord::Migration
  def change
  	rename_column :responses, :value, :text_value
  end
end
