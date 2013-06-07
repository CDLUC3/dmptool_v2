class AddCookieSaltToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cookie_salt, :string
  end
end
