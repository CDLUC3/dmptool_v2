class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :plan

  validates_columns :visibility
  validates :user_id, presence: true, numericality: true
  validates :plan_id, presence: true, numericality: true
  validates :visibility, presence: true
  validates :value, presence: true

  def owner?
    visibility == :owner
  end

  def reviewer?
    visibility == :reviewer
  end

end
