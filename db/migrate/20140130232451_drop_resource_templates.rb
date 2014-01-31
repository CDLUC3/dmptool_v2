class DropResourceTemplates < ActiveRecord::Migration
  def up
    drop_table :resource_templates
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
