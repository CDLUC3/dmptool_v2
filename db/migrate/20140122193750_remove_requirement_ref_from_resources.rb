class RemoveRequirementRefFromResources < ActiveRecord::Migration
  def change
    remove_reference :resources, :requirement, index: true
  end
end
