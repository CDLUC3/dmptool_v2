class Authentication < ActiveRecord::Base

  belongs_to :user

  validates_columns :provider
  validates :user_id, presence: true, numericality: true
  validates :provider, presence: true
  validates :uid, presence: true

end
