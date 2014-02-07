class ChangeResourceTypeColumnTypeInResources < ActiveRecord::Migration
  def self.up
    change_column :resources, :resource_type,  :enum, limit: [:actionable_url, :help_text, :example_response, :suggested_response]
  end
 
  def self.down
    change_column :resources, :resource_type,  :text 
  end
end
