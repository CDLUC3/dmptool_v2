require 'capistrano-unicorn'
#require "bundler/capistrano"

set :application, "dmptool2"
set :repository,  "git@bitbucket.org:dmptool/dmptool2.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
               # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :user, "jhubbard"
set :use_sudo, true
set :unicorn_user, 'dmp2'
#set :unicorn_roles, 'dmp2'
set :admin_runner, 'dmp2'
set :runner, 'dmp2'
set :sudo, 'sudo -iu dmp2'
set :deploy_via, :remote_cache
set :deploy_to, "/dmp2/apps/dmp2/"
set :branch, fetch(:branch, "master")
set :env, fetch(:env, "development")

default_run_options[:pty] = true
#ssh_options[:forward_agent] = true

role :web, "dmp2-dev.cdlib.org"
role :app, "dmp2-dev.cdlib.org"
role :db,  "dmp2-dev.cdlib.org", :primary => true # This is where Rails migrations will run

namespace :deploy do
  task :symlink_shared do
    run "ln -s #{shared_path}/database.yml #{release_path}/config/"
    run "ln -s #{shared_path}/ldap.yml #{release_path}/config/"
    run "ln -s #{shared_path}/unicorn.rb #{release_path}/config/"
    run "ln -s #{shared_path}/unicorn.rb #{release_path}/config/unicorn/"
    run "ln -s #{shared_path}/unicorn.rb #{release_path}/config/unicorn/production.rb"
  end
end

before "deploy:restart", "deploy:symlink_shared"

after 'deploy:restart', 'unicorn:reload' # app IS NOT preloaded
#after 'deploy:restart', 'unicorn:restart'  # app preloaded
