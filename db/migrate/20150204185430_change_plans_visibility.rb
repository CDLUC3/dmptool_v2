class ChangePlansVisibility < ActiveRecord::Migration
  def change
    change_column :plans, :visibility, :enum, limit: [:institutional, :public, :private, :unit]
  end
end
