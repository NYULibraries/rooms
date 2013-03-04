# Load bundler-capistrano gem
require "bundler/capistrano"
# Load rvm-capistrano gem
require "rvm/capistrano"
# Newrelic
require 'new_relic/recipes'

# Environments
set :stages, ["staging", "production"]
set :default_stage, "staging"
# Multistage
require 'capistrano/ext/multistage'

set :ssh_options, {:forward_agent => true}
set :app_title, "room_reservation"
set :application, "#{app_title}_repos"

# RVM  vars
set :rvm_ruby_string, "1.9.3-p125"

# Bundle vars

# Git vars
set :repository, "git@github.com:NYULibraries/room_reservation.git" 
set :scm, :git
set :deploy_via, :remote_cache
set(:branch, 'master') unless exists?(:branch)
set :git_enable_submodules, 1

set :keep_releases, 5
set :use_sudo, false

# Rails specific vars
set :normalize_asset_timestamps, false

# Deploy tasks
namespace :deploy do
  desc "Start Application"
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job start"
  end
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  task :passenger_symlink do
    run "rm -rf #{app_path}#{app_title} && ln -s #{current_path}/public #{app_path}#{app_title}"
  end
end

namespace :cache do
  desc "Clear rails cache"
  task :tmp_clear, :roles => :app do
    run "cd #{current_release} && bundle exec rake tmp:clear RAILS_ENV=#{rails_env}"
  end
  desc "Clear memcache after deployment"
  task :clear, :roles => :app do
    run "cd #{current_release} && bundle exec rake cache:clear RAILS_ENV=#{rails_env}"
  end
end

before "deploy", "rvm:install_ruby", "deploy:migrations"
after "deploy", "deploy:cleanup", "deploy:passenger_symlink", "cache:clear", "cache:tmp_clear"
after "deploy:update", "newrelic:notice_deployment"
