source 'https://rubygems.org'

gem 'rails', '~> 3.2.15'

gem 'mysql2', '~> 0.3.11'

# Move this out here to use coffee in views
gem 'coffee-rails', '~> 3.2.0'
gem 'uglifier', '~> 2.2.1'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '~> 0.12.0'

  gem 'compass', '~> 0.12.1'
  gem 'compass-rails', '~> 1.0.3'
  gem 'yui-compressor', '~> 0.12.0'
  gem 'temporal-rails', '~> 0.2.3'
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
  gem 'coveralls', '~> 0.7.0', :require => false
  gem 'vcr', '~> 2.6.0'
  gem 'webmock', '~> 1.15.0'
end

gem 'debugger', :groups => [:development, :test, :staging]

gem 'json', '~> 1.8.0'

gem 'jquery-rails', '~> 3.0.4'
gem 'jquery-ui-rails', '~> 4.0.0'

# Authenticate gem
gem 'authpds-nyu', :git => 'git://github.com/NYULibraries/authpds-nyu.git', :tag => 'v1.1.2'
gem 'nyulibraries_assets', :git => 'git://github.com/NYULibraries/nyulibraries_assets.git', :tag => 'v1.2.0'
gem 'nyulibraries_deploy', :git => 'git://github.com/NYULibraries/nyulibraries_deploy.git', :tag => 'v3.2.0'
gem 'cancan', '~> 1.6.10'

# Pagination and sorting
gem 'kaminari', '~> 0.13'
gem 'sorted', '~> 0.4.3'
#gem 'acts_as_paranoid', '~> 0.4.0'
gem 'acts_as_indexed', '~> 0.8.3'

# Settings
gem 'rails_config', '~> 0.3.2'

gem 'mustache-rails', '~> 0.2.3', :require => 'mustache/railtie'

# memcached
gem 'dalli', '~> 2.6'

# Comma
gem 'comma', '~> 3.1.1'

# ElasticSearch w/Tire
gem 'tire', '~> 0.6.0'

# New Relic
gem 'newrelic_rpm', '~> 3.6.0'

# For decorators
gem 'draper', '~> 1.3'
