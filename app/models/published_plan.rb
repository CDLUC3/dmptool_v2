class PublishedPlan < ActiveRecord::Base

  belongs_to :plan

  validates_columns :visibility
  validates :plan_id, presence: true, numericality: true
  validates :file_name, presence: true
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
