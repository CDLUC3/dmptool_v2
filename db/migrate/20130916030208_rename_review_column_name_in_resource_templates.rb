class RenameReviewColumnNameInResourceTemplates < ActiveRecord::Migration
  def change
  	rename_column :resource_templates, :mandatory_review, :review_type
  end
end
