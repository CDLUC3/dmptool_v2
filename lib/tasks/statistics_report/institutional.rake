namespace :statistics_report do
  desc 'Create monthly institutional statistics reports'
  task institutional: :environment do
    end_date = Date.today.prev_day
    start_date = Date.parse(end_date.strftime('%Y-%m-01'))
    
    Institution.find_each do |inst|
      # If the institution has active users
      if inst.users.where(active: true).count > 0
        stats = InstitutionStatistics.new(institution: inst, 
                                          created_at: Date.today,
                                          updated_at: Date.today,
                                          month: start_date.strftime('%m/%Y'), 
                                          all_users: inst.users.where(active: true).count ||= 0,
                                          users_created: inst.users.where(created_at: start_date..end_date).count ||= 0)
        
        #puts "Total: #{inst.users.where(active: true).count}"
        #puts "Created: #{inst.users.where(created_at: start_date..end_date).count ||= 0}"
        
        puts stats.inspect
      end
    end
  end
end
