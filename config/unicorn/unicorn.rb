require 'socket'

rails_env = ENV['RAILS_ENV'] 
puts ENV['RAILS_ENV'] if ENV['RAILS_ENV'].!=("production")
puts "socket:20225" if ENV['RAILS_ENV'].!=("production")

# 4 workers and 1 master
worker_processes 4

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

#pid File.join(Dir.pwd, "log", "unicorn.pid")
#pid File.join(Dir.pwd, "log", "unicorn.dmptool.pid")
 
#pid '/dmp/apps/ui/current/log/unicorn.pid'
#pid '/dmp/apps/ui/current/log/unicorn.dmptool.pid'

# timeout is long because we upload files
# switch to nginx to fix
timeout 3000

listen "#{Socket.gethostname}:18880"

# logs
stderr_path "/dmp2/apps/dmp2/current/log/unicorn.stderr.log"
stdout_path "/dmp2/apps/dmp2/current/log/unicorn.stdout.log"

#logger Logger.new(File.join(Dir.pwd, "log", "unicorn.log"))
logger Logger.new('/dmp2/apps/dmp2/current/log/unicorn.log')
before_fork do |server, worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.
 
  old_pid = '/dmp2/apps/dmp2/current/tmp/pids/unicorn.pid.oldbin'
  #old_pid = '/dmp/apps/ui/current/log/unicorn.dmptool.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
 
 
after_fork do |server, worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

