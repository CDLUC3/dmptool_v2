class PermissionGroup < ActiveRecord::Base

  belongs_to :institution

  validates :group, presence: true, numericality: true
  validates :institution_id, presence: true, numericality: true

end
