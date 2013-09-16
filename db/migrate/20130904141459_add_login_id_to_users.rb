class AddLoginIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login_id, :string

    User.all.each do |user|
      user.login_id = user.email
      user.save
    end
  end
end
