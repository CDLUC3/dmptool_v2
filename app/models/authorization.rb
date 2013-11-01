class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  has_many :permission_groups
  has_many :institutions, through: :permission_groups
  validates :role_id, presence: true
  validates :user_id, presence: true, numericality: true

  validates :id, uniqueness: { scope: [:user_id, :role_id] , message: "This Role for this User has already been taken." }
end
