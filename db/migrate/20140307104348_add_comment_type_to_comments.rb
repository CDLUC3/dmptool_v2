class AddCommentTypeToComments < ActiveRecord::Migration
  def change
    add_column :comments, :comment_type, :enum, limit: [:owner, :reviewer]
  end
end
