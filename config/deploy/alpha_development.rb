role :web, 'dmp2-dev.cdlib.org'
role :app, 'dmp2-dev.cdlib.org'
role :db,  'dmp2-dev.cdlib.org', :primary => true # This is where Rails migrations will run

set :deploy_to, "/dmp2/apps/dmp2-alpha/"
set :unicorn_pid, "/dmp2/apps/dmp2-alpha/shared/tmp/unicorn.dmp2.pid"