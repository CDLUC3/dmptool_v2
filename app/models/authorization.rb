class Authorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  has_many :permission_groups
  has_many :institutions, through: :permission_groups
  validates :role_id, presence: true
  validates :user_id, presence: true, numericality: true
end
