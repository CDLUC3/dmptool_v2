require 'capistrano/ext/multistage'
require 'capistrano-unicorn'
require 'bundler/capistrano'

set :application, 'dmptool2'
set :repository,  'git@bitbucket.org:dmptool/dmptool2.git'

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names

set :user, 'dmp2'
set :deploy_via, :remote_cache
set :branch, fetch(:branch, 'master')
set :env, fetch(:env, 'development')
set :rails_env, fetch(:renv, 'development')
set :ssh_options, { :forward_agent => true }
set :use_sudo, false

default_run_options[:env] = { 'PATH' => '/dmp2/local/bin/:$PATH'}
default_run_options[:pty] = true


namespace :deploy do
  task :symlink_shared do
    run "ln -s #{shared_path}/database.yml #{release_path}/config/"
    run "ln -s #{shared_path}/shibboleth.yml #{release_path}/config/"
    run "ln -s #{shared_path}/ldap.yml #{release_path}/config/"
    run "ln -s #{shared_path}/unicorn.rb #{release_path}/config/"
    run "ln -s #{shared_path}/uploads #{release_path}/public/uploads"
  end
end



