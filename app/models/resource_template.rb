class ResourceTemplate < ActiveRecord::Base

  belongs_to :institution
  has_many :resources

  validates :name, presence: true

  after_initialize  :default_values

  def default_values
    self.active ||= false
  end
end
