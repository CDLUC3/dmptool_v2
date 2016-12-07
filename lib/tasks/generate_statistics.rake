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
    
      run_date = "#{date.year}-#{"0#{date.month}".slice(-2, 2)}"
    
      # Only run if we haven't already recorded the stats for this round
      if !GlobalStatistic.find_by(run_date: run_date).nil?
        log.warn "The system has already generated statistics for #{run_date}. Canceling run."
      
      else
        log.info "Generating statistics #{start} - For cycle: #{first.to_s} - #{last.to_s}"
      
        n_users, t_users = 0, 0
        n_plans, t_plans = 0, 0
    
        # Collect the institution specific statistics
        Institution.all.each do |inst|
          stat = inst.statistics.find_by(run_date: run_date)
        
          # If we haven't already generated the stat for this instition
          if stat.nil?
            
            inst_plans = Plan.institutional_visibility.joins(:users).where(user_plans: {owner: true}).joins(:users).where("users.institution_id = ?", inst.id) 
            unit_plans = Plan.unit_visibility.joins(:users).where(user_plans: {owner: true}).joins(:users).where("users.institution_id = ?", inst.id)
            priv_plans = Plan.private_visibility.where("plans.created_at >= '2016-09-26 00:00:01'").joins(:users).where("users.institution_id = ?", inst.id)
            pub_plans = Plan.public_visibility.joins(:users).where("users.institution_id = ?", inst.id)
            
            plans = inst_plans + unit_plans + pub_plans + priv_plans
            
            stat = InstitutionStatistic.new({
              run_date: run_date,
              new_users: inst.users.select{ |u| u.created_at.between?(first, last) }.count,
              total_users: inst.users.select{ |u| u.created_at <= last }.count,
              new_completed_plans: plans.select{ |p| p.created_at.between?(first, last) }.count,
              total_completed_plans: plans.select{ |p| p.created_at <= last }.count
            })
          end
      
          n_users += stat.new_users
          t_users += stat.total_users
          n_plans += stat.new_completed_plans
          t_plans += stat.total_completed_plans
      
          inst.statistics << stat
          inst.save!
        end
      
        # Collect the public template statistics
        RequirementsTemplate.where(active: true).each do |tmplt|
          stat = tmplt.statistics.find_by(run_date: run_date)
        
          if stat.nil?
            stat = RequirementsTemplateStatistic.new({
              run_date: run_date,
              new_plans: tmplt.plans.select{ |t| (t.visibility != :test &&  t.created_at.between?(first, last)) }.count,
              total_plans: tmplt.plans.select{ |t| (t.visibility != :test && t.created_at <= last) }.count
            })
          end
        
          tmplt.statistics << stat
          tmplt.save!
        end
    
        plans = Plan.where("visibility != ?", :test)
        users = User.all
        
        # create the global stats record
        GlobalStatistic.create({
          run_date: run_date,
          effective_month: "#{Date::MONTHNAMES[first.month]}",
          new_users: users.select{ |u| u.created_at.between?(first, last) }.count,
          total_users: users.select{ |u| u.created_at <= last }.count,
          new_completed_plans: plans.select{ |p| p.created_at.between?(first, last) }.count,
          total_completed_plans: plans.select{ |p| p.created_at <= last }.count,
          new_public_plans: plans.select{ |p| (p.visibility == :public && p.created_at.between?(first, last)) }.count,
          total_public_plans: plans.select{ |p| (p.visibility == :public && p.created_at <= last) }.count,
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
