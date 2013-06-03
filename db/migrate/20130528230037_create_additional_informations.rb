class CreateAdditionalInformations < ActiveRecord::Migration
  def change
    create_table :additional_informations do |t|
      t.string :url
      t.string :label
      t.integer :requirements_template_id

      t.timestamps
    end
  end
end
