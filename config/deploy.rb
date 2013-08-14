require "capistrano/ext/multistage"

DEPLOY_CONFIG = YAML.load_file('config/deploy.yml')

set :application, "dmptool2"
set :repository,  "git@bitbucket.org:dmptool/dmptool2.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
               # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :user, DEPLOY_CONFIG['username']
set :password, DEPLOY_CONFIG['password']
set :use_sudo, true
set :unicorn_user, 'dmp2'
set :admin_runner, 'dmp2'
set :git_user, 'dmp2'
set :runner, 'dmp2'
set :deploy_user, 'dmp2'
set :sudo, 'sudo -iu dmp2'
set :deploy_via, :remote_cache
set :branch, fetch(:branch, "master")
set :env, fetch(:env, "development")
set :ssh_options, {:forward_agent => true }

default_run_options[:env] = { 'PATH' => '/dmp2/local/bin/:$PATH'}
default_run_options[:pty] = true

role :web, "dmp2-dev.cdlib.org"
role :app, "dmp2-dev.cdlib.org"
role :db,  "dmp2-dev.cdlib.org", :primary => true # This is where Rails migrations will run

namespace :deploy do
  task :symlink_shared do
    run "ln -s #{shared_path}/database.yml #{release_path}/config/"
    run "ln -s #{shared_path}/ldap.yml #{release_path}/config/"
    run "ln -s #{shared_path}/unicorn.rb #{release_path}/config/"
    run "chmod -R 777 #{current_path}/tmp"
  end
end

before "deploy:restart", "deploy:symlink_shared"

after 'deploy:restart', 'unicorn:restart'


namespace :unicorn do
  def pid_path
    "#{shared_path}/tmp/unicorn.dmp2.pid"
  end

  def socket_path
    "#{shared_path}/sockets/unicorn.sock"
  end

  def check_pid_path_then_run(command)
    run <<-CMD
      if [ -s #{pid_path} ]; then
        #{command}
      else
        echo "Unicorn master worker wasn't found, possibly wasn't started at all. Try run unicorn:start first";
      fi
    CMD
  end

  desc "Starts the Unicorn server"
  task :start do
    run "sudo -iu dmp2 mkdir -p #{File.dirname(pid_path)}"
    run "sudo -iu dmp2 mkdir -p #{File.dirname(socket_path)}"
    run <<-CMD
      if [ ! -s #{pid_path} ]; then
        cd #{current_path} ; sudo -iu dmp2 unicorn -c #{current_path}/config/unicorn.rb -D -E development;
      else
        echo "Unicorn is already running at PID: `cat #{pid_path}`";
      fi
    CMD
  end

  desc "Stops Unicorn server"
  task :stop do
    check_pid_path_then_run "sudo -iu dmp2 kill -s QUIT `cat #{pid_path}`;"
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :roles => :app, :except => { :no_release => true } do
    check_pid_path_then_run "sudo -iu dmp2 kill -USR2 `cat #{pid_path}`;"
  end
end