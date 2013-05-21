class Institution < ActiveRecord::Base

  has_many :users

  validates :full_name, presence: true

end
