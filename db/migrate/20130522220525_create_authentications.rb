class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer :user_id
      t.column :provider, :enum, limit: [:shibboleth, :ldap]
      t.string :uid

      t.timestamps
    end
  end
end
