class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.string :desc
      t.string :group

      t.timestamps
    end
  end
end
