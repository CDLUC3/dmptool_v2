namespace :statistics_report do
  desc 'Create monthly institutional statistics reports'
  task institutional: :environment do
    end_date = Date.today.prev_day
    start_date = Date.parse(end_date.strftime('%Y-%m-01'))
    
    Institution.find_each do |inst|
      # If the institution has active users
      if inst.users.where(active: true).count > 0
        users = inst.users.where(active: true)
        
        plans = Plan.plans_per_institution(inst)
        completed_plans = plans.joins(:current_state).where('plan_states.state =?', :committed)
        public_plans = plans.where(visibility: :public)
        
        stats = InstitutionStatistics.new(
            institution: inst, 
            created_at: Date.today,
            updated_at: Date.today,
            month: start_date.strftime('%m/%Y'), 
            total_users: users.count ||= 0,
            new_users: users.where(created_at: start_date..end_date).count ||= 0,
            unique_users: users.joins(:authentications).where(updated_at: start_date..end_date).count ||= 0,
            new_completed_plans: completed_plans.where(created_at: start_date..end_date).count ||= 0,
            new_public_plans: public_plans.where(created_at: start_date..end_date).count ||= 0,
            total_public_plans: public_plans.count ||= 0)
        
        #puts "Total: #{inst.users.where(active: true).count}"
        #puts "Created: #{inst.users.where(created_at: start_date..end_date).count ||= 0}"
        
        puts stats.inspect
      end
    end
  end
end

=begin
Global stats for monthly report

    New/unique users (/month)
    Total n users
    New completed plans (/month)
    Total n completed plans
    New plans with public visibility (/month)
    Total n public plans 
    New institutions (/month)
    Total n institutions (excluding Non-Partner Institution)
    (Public) template of the month (public template with highest frequency of use/month)
    New plans/public template (/month)
    Total plans/public template

And something like this, but I’m open to suggestions

    Top 10? Institutions by users
    Top 10? Institutions by plans

=end