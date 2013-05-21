class Plan < ActiveRecord::Base

  validates_columns :visibility
  validates :name, presence: true
  validates :visibility, presence: true

  def public?
    visibility == :public
  end

  def public_browsable?
    visibility == :public_browsable
  end

  def institutional?
    visibility == :institutional
  end
end
