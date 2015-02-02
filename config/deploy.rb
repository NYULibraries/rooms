require 'formaggio/capistrano'
set :app_title, "rooms"
set :recipient, "rooms.admin@library.nyu.edu"
# Run using ruby 2.1.5
set :rvm_ruby_string, "ruby-2.1.5"

set :rvm_ruby_string, "ruby-2.1.5"

namespace :reporting do
  desc "Startup delayed jobs script"
  task :cache do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake cache:reporting"
  end
end
