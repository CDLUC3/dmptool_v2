class AddReviewedStateToPlanStates < ActiveRecord::Migration
  def change
    change_column(:plan_states, :state,
                  :enum, limit:
                        [:new, :committed, :submitted, :approved, :reviewed, :rejected, :revised, :inactive, :deleted])
  end
end
