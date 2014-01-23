class CreateResourceContexts < ActiveRecord::Migration
  def change
    create_table :resource_contexts do |t|
      t.belongs_to :institution, index: true
      t.belongs_to :requirements_template, index: true
      t.belongs_to :resource_template, index: true
      t.belongs_to :requirement, index: true

      t.timestamps
    end
  end
end
