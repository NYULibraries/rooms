require 'formaggio/capistrano'
set :app_title, "rooms"
set :recipient, "rooms.admin@library.nyu.edu"

namespace :reporting do
  desc "Startup delayed jobs script"
  task :cache do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake cache:reporting"
  end
end
