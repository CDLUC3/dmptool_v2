class Label < ActiveRecord::Base

  has_many :responses

  validates :desc, presence: true
  validates :group, presence: true

end
