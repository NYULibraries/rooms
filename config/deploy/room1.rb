set :rails_env, "production"
# Vars loaded via rails_config
(set :app_settings, eval(run_locally("rails runner -e #{rails_env} 'puts \"{ :scm_username => \" + Settings.capistrano.scm_username.inspect + \", :app_path => \" + Settings.capistrano.path.inspect + \", :user => \" + Settings.capistrano.user.inspect + \", :server1 => \" + Settings.capistrano.server1.inspect + \", :server2 => \" + Settings.capistrano.server2.inspect + \" } \"'")))
set :rvm_type, :user
set :scm_username, app_settings[:scm_username]
set :app_path, app_settings[:app_path]
set :user, app_settings[:user]
set :server2, app_settings[:server2]
server "#{server2}", :app, :web, :db, :primary => true
set :deploy_to, "#{app_path}#{application}"
set :branch, "master"
