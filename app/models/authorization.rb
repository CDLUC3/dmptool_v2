class Authorization < ActiveRecord::Base

  belongs_to :user
  belongs_to :role
  validates :role_id, presence: true
  validates :group, presence: true, numericality: true
  validates :user_id, presence: true, numericality: true

  def institutions
    PermissionGroup.where(group: self.group).map(&:institution_id)
  end

end
