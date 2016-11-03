source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'

gem 'mysql2', '~> 0.3.17'

# Use CoffeeScript in assets and views
gem 'coffee-rails'#, '~> 4.1.0'

gem 'uglifier', '~> 2.7.0'
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
gem 'jquery-ui-rails', '~> 5.0.5'

# CanCanCan for authorization
gem 'cancancan', '~> 1.10.1'

# Kaminaro for pagination
gem 'kaminari', '~> 0.16.1'

# Sorted for making sortable tables
gem 'sorted', '~> 1.0.1'

# ActsAsIndexed for searching activemodel
gem 'acts_as_indexed', '~> 0.8.3'

# Dalli for memcached
gem 'dalli', '~> 2.7.4'

# Comma
gem 'comma', '~> 3.2.2'

# Tire for elasticsearch
gem 'tire', '~> 0.6.2' # Doesn't officially support ElasticSearch 1.x
gem 'rest-client', '~> 1.8.0'

# Draper for decorators
gem 'draper', '~> 1.4.0'

gem 'newrelic_rpm', '~> 3.16'

gem 'nyulibraries_stylesheets', git: 'https://github.com/NYULibraries/nyulibraries_stylesheets'
gem 'nyulibraries_templates', git: 'https://github.com/NYULibraries/nyulibraries_templates'
gem 'nyulibraries_institutions', git: 'https://github.com/NYULibraries/nyulibraries_institutions'
gem 'nyulibraries_javascripts', git: 'https://github.com/NYULibraries/nyulibraries_javascripts'
gem 'nyulibraries_errors', git: 'https://github.com/NYULibraries/nyulibraries_errors', tag: 'v1.0.0'
gem 'formaggio', git: "https://github.com/NYULibraries/formaggio", tag: 'v1.5.2'
gem 'omniauth-nyulibraries', git: 'https://github.com/NYULibraries/omniauth-nyulibraries', tag: 'v2.0.0'
gem 'devise', '~> 3.5'

gem 'font-awesome-rails', '~> 4.2.0'

group :development, :test do
  gem 'pry', '~> 0.10.1'
  # Use factory girl for creating models
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'faker'
  gem 'pry-remote'
end

group :test do
  gem 'json_spec'
  gem 'progress_bar'
  #Testing coverage
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'coveralls', '~> 0.7.1', :require => false
  gem 'webmock', '>= 1.8.0', '< 1.16'
  gem 'timecop', '~> 0.7.1'
  gem 'rspec-rails', '~> 3.4.1'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'phantomjs', '>= 1.9.0'
  gem 'poltergeist', '~> 1.10.0'
  gem 'selenium-webdriver'
end
