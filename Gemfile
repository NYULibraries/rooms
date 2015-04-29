source 'https://rubygems.org'

gem 'rails', '~> 4.1.9'

gem 'mysql2', '~> 0.3.17'

# Use CoffeeScript in assets and views
gem 'coffee-rails', '~> 4.1.0'

gem 'uglifier', '~> 2.5.3'
gem 'therubyracer', '~> 0.12.1'

# Use Compass
gem 'compass-rails', '~> 2.0.4'
gem 'yui-compressor', '~> 0.12.0'

# Temporal-rails for manipulating timezones via javascript cookies
gem 'temporal-rails', '~> 0.2.3'

# Use Sass
gem 'sass-rails', '~> 5.0.1'

gem 'json', '~> 1.8.1'

# Use jQuery
gem 'jquery-rails', '~> 3.1.2'
gem 'jquery-ui-rails', '~> 4.2.1'

# CanCanCan for authorization
gem 'cancancan', '~> 1.10.1'

# Kaminaro for pagination
gem 'kaminari', '~> 0.16.1'

# Sorted for making sortable tables
gem 'sorted', '~> 1.0.1'

# ActsAsIndexed for searching activemodel
gem 'acts_as_indexed', '~> 0.8.3'

# Mustache for templating
gem 'mustache', '0.99.4'
gem 'mustache-rails', git: 'git://github.com/josh/mustache-rails.git', :require => 'mustache/railtie'

# Dalli for memcached
gem 'dalli', '~> 2.7.2'

# Comma
gem 'comma', '~> 3.2.2'

# Tire for elasticsearch
gem 'tire', '~> 0.6.2' # Doesn't officially support ElasticSearch 1.x
gem 'rest-client', '~> 1.8.0'

# Draper for decorators
gem 'draper', '~> 1.4.0'

gem 'newrelic_rpm', '~> 3.9.6.257'

gem 'exlibris-aleph', github: 'barnabyalter/exlibris-aleph'
gem 'authpds', github: 'barnabyalter/authpds'
gem 'authpds-nyu', github: 'barnabyalter/authpds-nyu'
gem 'nyulibraries-assets', github: 'NYULibraries/nyulibraries-assets', tag: 'v4.4.0'
gem 'formaggio', github: "NYULibraries/formaggio", tag: 'v1.4.2'

gem 'font-awesome-rails', '~> 4.2.0'

group :development do
  gem 'progress_bar'
end

group :test do
  #Testing coverage
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'coveralls', '~> 0.7.1', :require => false
  gem 'vcr', '~> 2.9.3'
  gem 'webmock', '~> 1.20.4'
  gem 'timecop', '~> 0.7.1'
  gem 'ruby-prof', '~> 0.15.2'
  gem 'rspec-rails', '~> 2.99.0'
  # Use factory girl for creating models
  gem 'factory_girl_rails', '~> 4.5.0'
end


group :development, :test do
  gem 'pry', '~> 0.10.1'
  gem 'faker'
end
