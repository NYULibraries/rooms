source 'https://rubygems.org'

gem 'rails', '~> 3.2.15'

gem 'mysql2', "~> 0.3.11"

# Move this out here to use coffee in views
gem 'coffee-rails', '~> 3.2.1'
gem 'uglifier', '~> 2.0.1'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', "~> 0.12.0"

  gem 'compass', '~> 0.12.1'
  gem 'compass-rails', "~> 1.0.3"
  gem 'yui-compressor', "~> 0.12.0"
end

group :development do
  gem 'progress_bar'
  # To use debugger
  #gem 'reek'
end

group :test do
  #Testing coverage
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'ruby-prof' #For Benchmarking
  gem 'coveralls', "~> 0.7.0", :require => false
end

gem 'json', '~> 1.8.0'

gem 'debugger', :groups => [:development, :test]

gem 'jquery-rails', '~> 2.2.1'

gem 'kaminari', "~> 0.13"
gem 'sorted', '~> 0.4.3'

# Deploy with Capistrano
gem "capistrano", "~> 2.15.0"
gem "capistrano-ext", "~> 1.2.1"
  
gem "rails_config", "~> 0.3.2"

gem 'nyulibraries_assets', :git => 'git://github.com/NYULibraries/nyulibraries_assets.git', :tag => 'v1.2.0'
gem 'authpds-nyu', :git => 'git://github.com/NYULibraries/authpds-nyu.git', :tag => 'v1.1.2'
gem 'nyulibraries_deploy', :git => 'git://github.com/NYULibraries/nyulibraries_deploy.git', :tag => 'v3.2.0'

gem 'mustache-rails', "~> 0.2.3", :require => 'mustache/railtie'

# memcached
gem 'dalli', "~> 2.6"

gem "comma", "~> 3.2.0"

# New Relic
gem 'newrelic_rpm', "~> 3.6.0"