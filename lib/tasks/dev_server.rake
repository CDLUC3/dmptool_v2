task :server do
  # optional port parameter
  port = ENV['PORT'] ? ENV['PORT'] : '3000'
  puts 'start unicorn development'
  # execute unicorn command specifically in development
  # port at 3000 if unspecified
  sh "cd #{Rails.root} && RAILS_ENV=development unicorn -p #{port}"
end
# an alias task
task :s => :server