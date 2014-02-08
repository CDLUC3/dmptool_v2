class MakeResourceValueText < ActiveRecord::Migration
  def self.up
    change_table :resources do |t|
      t.change :value, :text
    end
  end
  
  def self.down
    change_table :resources do |t|
      t.change :value, :string
    end
  end
end
