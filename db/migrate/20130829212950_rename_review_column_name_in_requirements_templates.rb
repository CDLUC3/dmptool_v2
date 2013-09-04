class RenameReviewColumnNameInRequirementsTemplates < ActiveRecord::Migration
  def change
  	rename_column :requirements_templates, :mandatory_review, :review_type
  end
end
