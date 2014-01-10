class UserPlan < ActiveRecord::Base

  belongs_to :user
  belongs_to :plan

  def owned
  	self.owner = true
  end

  def coowned
  	self.owner = false
  end
end
