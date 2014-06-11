
# #old staging.rb, before assets

# role :web, 'dmp2-stage.cdlib.org'
# role :app, 'dmp2-stage.cdlib.org'
# role :db,  'dmp2-stage.cdlib.org', :primary => true # This is where Rails migrations will run

# set :deploy_to, "/dmp2/apps/dmp2/"
# set :unicorn_pid, "/dmp2/apps/dmp2/shared/tmp/unicorn.dmp2.pid"
# set :rails_env, "stage"

# after 'deploy', 'deploy:migrate'
# before 'deploy:restart', 'deploy:symlink_shared'
# after 'deploy:restart', 'unicorn:restart'


role :web, 'dmp2-stage.cdlib.org'
role :app, 'dmp2-stage.cdlib.org'
role :db,  'dmp2-stage.cdlib.org', :primary => true # This is where Rails migrations will run

set :deploy_to, "/dmp2/apps/dmp2/"
set :unicorn_pid, "/dmp2/apps/dmp2/shared/tmp/unicorn.dmp2.pid"
set :rails_env, "stage"


after 'deploy', 'deploy:migrate'
after 'deploy:finalize_update', 'deploy:symlink_shared'
load  'deploy/assets'
after 'deploy:restart', 'unicorn:restart'
