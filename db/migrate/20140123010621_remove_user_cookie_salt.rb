class RemoveUserCookieSalt < ActiveRecord::Migration
  def up
    remove_column :users, :cookie_salt
  end
  def down
    add_column :users, :cookie_salt, :string
  end
end
