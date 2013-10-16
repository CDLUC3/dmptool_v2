role :web, 'dmp2-stage.cdlib.org'
role :app, 'dmp2-stage.cdlib.org'
role :db,  'dmp2-stage.cdlib.org', :primary => true # This is where Rails migrations will run

set :deploy_to, "/dmp2/apps/dmp2/"
set :unicorn_pid, "/dmp2/apps/dmp2/shared/tmp/unicorn.dmp2.pid"