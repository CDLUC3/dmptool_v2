namespace :statistics_report do
  desc 'Create monthly institutional statistics reports'
  task institutional: :environment do
    mstamp = Date.today().strftime('%m-%Y')
    
    # Total user count per Institution
    Institution.find_each do |inst|
      if inst.users.where(active: true).count > 0
        Dir.mkdir("#{Dir.pwd}/tmp/reports/") unless Dir.exist?("#{Dir.pwd}/tmp/reports/")
        file_name = "#{Dir.pwd}/tmp/reports/#{inst.full_name.rstrip().gsub(/\s/, '_')}-#{mstamp}.txt"

  puts "Generating report: #{file_name}"

        rpt = File.open(file_name, 'w')
      
        rpt.write("DMPTool Statistics for #{inst.full_name} - #{mstamp}\n\n")
        rpt.write("\tTotal number of active users: #{inst.users.where(active: true).count}")
        rpt.close
        
      end
    end
  end
end
