class AddPlansTestVisibility < ActiveRecord::Migration
  def change
    change_column :plans, :visibility, :enum, limit: [:institutional, :public, :private, :unit, :test]
  end
end
