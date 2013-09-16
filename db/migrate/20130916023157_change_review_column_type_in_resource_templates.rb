class ChangeReviewColumnTypeInResourceTemplates < ActiveRecord::Migration
 	def change
  	change_column :resource_templates, :mandatory_review, :enum, limit: [:formal_review, :informal_review, :no_review]
  end
end