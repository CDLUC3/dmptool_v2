class AddReviewTypeColumnToResourceContexts < ActiveRecord::Migration
  def change
    add_column :resource_contexts, :review_type, :boolean
  end
end
