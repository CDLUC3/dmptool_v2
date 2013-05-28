class ResourceTemplate < ActiveRecord::Base

  belongs_to :institution
  has_many :resources
  belongs_to :requirements_template

  validates :name, presence: true

  after_initialize  :default_values

  def default_values
    self.active ||= false
  end
end
