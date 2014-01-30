class ChangeReviewTypeColumnTypeInResourceContexts < ActiveRecord::Migration
  # def change
  # 	change_column :resource_contexts, :review_type, :enum, limit: [:formal_review, :informal_review, :no_review]
  # end
  def self.up
    change_column :resource_contexts, :review_type, :enum, limit: [:formal_review, :informal_review, :no_review]
  end
 
  def self.down
    change_column :resource_contexts, :review_type, :text
  end
end
