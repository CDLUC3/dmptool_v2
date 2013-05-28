class Requirement < ActiveRecord::Base

  validates_columns :requirement_type, :obligation
  validates :text_brief, presence: true
  validates :validations

  def validations
    @is_parent ||= Requirement.where(parent_id: self.id).count == 0

    unless @is_parent
      #Is leaf

    end
  end
end
