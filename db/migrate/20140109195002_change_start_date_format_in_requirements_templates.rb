class ChangeStartDateFormatInRequirementsTemplates < ActiveRecord::Migration
  def up
   change_column :requirements_templates, :start_date, :date
  end

  def down
   change_column :requirements_templates, :start_date, :datetime
  end
end
