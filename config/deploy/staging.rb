set :rails_env, "staging"
# Vars loaded via rails_config
(set :app_settings, eval(run_locally("rails runner -e #{rails_env} 'puts \"{ :scm_username => \" + Settings.capistrano.scm_username.inspect + \", :app_path => \" + Settings.capistrano.path.inspect + \", :user => \" + Settings.capistrano.user.inspect + \", :server => \" + Settings.capistrano.server.inspect + \" } \"'")))
set :rvm_type, :user
set :scm_username, app_settings[:scm_username]
set :app_path, app_settings[:app_path]
set :user, app_settings[:user]
set :host, app_settings[:server]
server "#{host}", :app, :web, :db, :primary => true
set :deploy_to, "#{app_path}#{application}"
#set :branch, "development"
