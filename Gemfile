source 'https://rubygems.org'

gem 'rails', '~> 3.2.17'

gem 'mysql2', '~> 0.3.11'

# Move this out here to use coffee in views
gem 'coffee-rails', '~> 3.2.0'
gem 'uglifier', '~> 2.5.0'

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
  gem 'coveralls', '~> 0.7.0', :require => false
  gem 'vcr', '~> 2.6.0'
  gem 'webmock', '~> 1.15.0'
  gem 'timecop', '~> 0.6.3'
  gem 'ruby-prof'
end

gem 'debugger', :groups => [:development, :test, :staging, :qa]

gem 'json', '~> 1.8.0'

gem 'jquery-rails', '~> 3.0.4'
gem 'jquery-ui-rails', '~> 4.1.0'

# Authenticate gem
gem 'authpds-nyu', :git => 'git://github.com/NYULibraries/authpds-nyu.git', :tag => 'v1.1.2'
gem 'nyulibraries-assets', :git => 'git://github.com/NYULibraries/nyulibraries-assets.git', :tag => 'v2.0.1'
gem 'nyulibraries-deploy', :git => 'git://github.com/NYULibraries/nyulibraries-deploy.git', :tag => 'v4.0.0'
gem 'cancan', '~> 1.6.10'

# Pagination and sorting
gem 'kaminari', '~> 0.13'
gem 'sorted', '~> 0.4.3'
#gem 'acts_as_paranoid', '~> 0.4.0'
gem 'acts_as_indexed', '~> 0.8.3'

# Settings
gem 'rails_config', '~> 0.3.3'

gem 'mustache', '0.99.4'
gem 'mustache-rails', '~> 0.2.3', :require => 'mustache/railtie'

# memcached
gem 'dalli', '~> 2.6.0'

# Comma
gem 'comma', '~> 3.2.0'

# ElasticSearch w/Tire
gem 'tire', '~> 0.6.2'

# New Relic
gem 'newrelic_rpm', '~> 3.6.0'

# For decorators
gem 'draper', '~> 1.3'

# Peek and plugins
gem 'peek'
gem 'peek-git'
gem 'peek-mysql2'
gem 'peek-dalli'
gem 'peek-performance_bar'
gem 'peek-rblineprof'

