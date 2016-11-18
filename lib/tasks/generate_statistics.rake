namespace :statistics do
  desc 'Generate monthly usage statistics'
  
  task generate: :environment do |t, args|
    date = Date.today
    
    last = Date.yesterday
    first = Date.new(last.year, last.month, 1)
    
    run_date = "#{date.year}-#{date.month}"
    
    # Only run if we haven't already recorded the stats for this round
    if !GlobalStatistic.find_by(run_date: run_date).nil?
      puts "The system has already generated statistics for #{run_date}"
      
    else
      puts "Generating statistics for #{run_date}"
      
      top_users, top_plans, top_templates = {}, {}, {}
      n_users, t_users = 0, 0
      n_plans, t_plans = 0, 0
    
      # Collect the institution specific statistics
      Institution.all.each do |inst|
        stat = inst.statistics.find_by(run_date: run_date)
        
        # If we haven't already generated the stat for this instition
        if stat.nil?
          stat = InstitutionStatistic.new({
            run_date: run_date,
            new_users: inst.users.where(created_at: first..last, active: true).count,
            total_users: inst.users.where(active: true).count,
            new_completed_plans: Plan.completed(inst).where(created_at: first..last).count,
            total_completed_plans: Plan.completed(inst).count
          })
        end
      
        top_users[inst.id] = stat.total_users
        top_plans[inst.id] = stat.total_completed_plans
      
        n_users += stat.new_users
        t_users += stat.total_users
        n_plans += stat.new_completed_plans
        t_plans += stat.total_completed_plans
      
        inst.statistics << stat
        inst.save!
      end
      
      # Collect the public template statistics
      RequirementsTemplate.where(visibility: 'public').each do |tmplt|
        stat = tmplt.statistics.find_by(run_date: run_date)
        
        if stat.nil?
          stat = PublicTemplateStatistic.new({
            run_date: run_date,
            new_plans: tmplt.plans.where(created_at: first..last).count,
            total_plans: tmplt.plans.count
          })
        end
        
        top_templates[tmplt.id] = stat.new_plans 
        
        tmplt.statistics << stat
        tmplt.save!
      end
    
      # Select the most used template for the period
      top_templates = Hash[top_templates.sort_by{|k,v| v}.reverse].first
    
      # Select the top ten institutions by user and plan
      top_users = Hash[top_users.sort_by{|k,v| v}.reverse[0..9]]
      top_plans = Hash[top_plans.sort_by{|k,v| v}.reverse[0..9]]
    
      # create the global stats record
      GlobalStatistic.create({
        run_date: run_date,
        new_users: n_users,
        total_users: t_users,
        new_completed_plans: n_plans,
        total_completed_plans: n_plans,
        new_public_plans: Plan.public_visibility.where(created_at: first..last).count,
        total_public_plans: Plan.public_visibility.count,
        new_institutions: Institution.where(created_at: first..last).count,
        total_institutions: Institution.all.count,
        template_of_the_month: (top_templates.nil? ? nil : top_templates[0]),
        top_ten_institutions_by_users: top_users.to_s,
        top_ten_institutions_by_plans: top_plans.to_s
      })
    
      puts "Process complete"
    end
    
  end
end
