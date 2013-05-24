class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.column :resource_type, :enum, limit: [:actionable_url, :expository_guidance, :example_response, :suggested_response]
      t.string :value
      t.string :label
      t.integer :requirement_id
      t.integer :resource_template_id

      t.timestamps
    end
  end
end
