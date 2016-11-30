namespace :statistics do
  desc 'Generate monthly usage statistics'
  
  task :generate, [:year, :month] => :environment do |t, args|
    log = ActiveSupport::Logger.new('log/statistics.log')
    start, continue = Time.now, true
    date = Date.new(Date.today.year, Date.today.month, 1)
    
    puts "Processing ... See log/statistics.log for more information"
    
    # If a year and date were passed in
    if args.count > 0
      if args[:year].match(/[0-9]{4}/).nil? || args[:month].match(/[0-9]{1,2}/).nil?
        log.info "Invalid arguments! To specify a date please use: 'rake statistics:generate[2016,05]'. Do not use spaces in the array!"
        continue = false
      else
        log.info "Using specified month and year - #{args[:year]}-#{args[:month]}"
        date = Date.new(args[:year].to_i, args[:month].to_i, 1)
      end
    else
      log.info "No year and month arguments provided so using prior month and year. To specify a date please use: 'rake statistics:generate[2016,05]'. Do not use spaces in the array!"
    end
    
    if continue
      if (date.month - 1) <= 0
        last = Date.civil((date.year - 1), 12, -1)
      else
        last = Date.civil(date.year, (date.month - 1), -1)
      end
    
      first = Date.new(last.year, last.month, 1)
    
      run_date = "#{date.year}-#{date.month}"
    
      # Only run if we haven't already recorded the stats for this round
      if !GlobalStatistic.find_by(run_date: run_date).nil?
        log.warn "The system has already generated statistics for #{run_date}. Canceling run."
      
      else
        log.info "Generating statistics #{start} - For cycle: #{first.to_s} - #{last.to_s}"
      
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
              total_users: inst.users.where("users.created_at <= ? AND users.active = true", last).count,
              new_completed_plans: Plan.completed(inst).where(created_at: first..last).count,
              total_completed_plans: Plan.completed(inst).where("plans.created_at <= ?", last).count
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
        RequirementsTemplate.where(visibility: 'public', active: true).each do |tmplt|
          stat = tmplt.statistics.find_by(run_date: run_date)
        
          if stat.nil?
            stat = PublicTemplateStatistic.new({
              run_date: run_date,
              new_plans: tmplt.plans.where(created_at: first..last, visibility: []).count,
              total_plans: tmplt.plans.where("plans.created_at <= ?", last).count
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
          effective_month: "#{Date::MONTHNAMES[first.month]}",
          new_users: n_users,
          total_users: t_users,
          new_completed_plans: n_plans,
          total_completed_plans: t_plans,
          new_public_plans: Plan.public_visibility.where(created_at: first..last).count,
          total_public_plans: Plan.public_visibility.where("plans.created_at <= ?", last).count,
          new_institutions: Institution.where(created_at: first..last).count,
          total_institutions: Institution.all.where("institutions.created_at <= ?", last).count
        })
      end
    end
    
    stop = Time.now
    log.info "Process completed at #{stop} - #{(start - stop) / 1.second} seconds"
    log.close
  end
end
