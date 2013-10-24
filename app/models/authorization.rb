class Authorization < ActiveRecord::Base

  belongs_to :user
  belongs_to :role
  validates :role_id, presence: true
  validates :user_id, presence: true, numericality: true
end
