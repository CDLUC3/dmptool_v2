class Authorization < ActiveRecord::Base

  belongs_to :user

  validates_columns :role
  validates :role, presence: true
  validates :group, presence: true, numericality: true
  validates :user_id, presence: true, numericality: true

  def institutions
    PermissionGroup.where(group: self.group).map(&:institution_id)
  end

  def dmp_owner?
    role == :dmp_owner
  end

  def dmp_co_owner?
    role == :dmp_co_owner
  end

  def requirements_editor?
    role == :requirements_editor
  end

  def resources_editor?
    role == :resources_editor
  end

  def institutional_reviewer?
    role == :institutional_reviewer
  end

  def institutional_administrator?
    role == :institutional_administrator
  end

  def dmp_administrator?
    role == :dmp_administrator
  end
end
