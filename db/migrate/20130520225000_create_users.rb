class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :institution_id
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :token
      t.timestamp :token_expiration
      t.binary :prefs

      t.timestamps
    end
  end
end
