class RemoveResourceTemplateRefFromResources < ActiveRecord::Migration
  def change
    remove_reference :resources, :resource_template, index: true
  end
end
