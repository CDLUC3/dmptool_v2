class ChangeEndDateFormatInRequirementsTemplates < ActiveRecord::Migration
  def up
   change_column :requirements_templates, :end_date, :date
  end

  def down
   change_column :requirements_templates, :end_date, :datetime
  end
end
