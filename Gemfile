source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'

gem 'mysql2', '~> 0.3.17'

# Use CoffeeScript in assets and views
gem 'coffee-rails', '~> 4.2.1'

gem 'uglifier', '~> 3.0.4'
gem 'therubyracer', '~> 0.12.2'

# Use Compass
gem 'compass-rails', '~> 3.0.2'
gem 'yui-compressor', '~> 0.12.0'

# Temporal-rails for manipulating timezones via javascript cookies
gem 'temporal-rails', '~> 0.2.3'

# Use Sass
gem 'sass-rails', '~> 5.0.6'

gem 'json', '~> 1.8.1'

# Use jQuery
gem 'jquery-rails', '~> 4.2.1'
gem 'jquery-ui-rails', '~> 6.0.1'

# Froze this at 1.11, because 1.12 exploded my application
# namely "ExecJS::ProgramError: ReferenceError: CoffeeScript is not defined"
# hopefully this will be fixed in the next version
gem 'coffee-script-source', '1.11.0'

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

# Elasticsearch
gem 'elasticsearch-model', '~> 0.1.9'
gem 'elasticsearch-rails', '~> 0.1.9'
gem 'elasticsearch-dsl', '~> 0.1.4'

gem 'rest-client', '~> 1.8.0'

gem 'newrelic_rpm', '~> 3.16'

gem 'nyulibraries_stylesheets', git: 'https://github.com/NYULibraries/nyulibraries_stylesheets', tag: 'v1.0.0'
gem 'nyulibraries_templates', git: 'https://github.com/NYULibraries/nyulibraries_templates', tag: 'v1.0.0'
gem 'nyulibraries_institutions', git: 'https://github.com/NYULibraries/nyulibraries_institutions', tag: 'v1.0.0'
gem 'nyulibraries_javascripts', git: 'https://github.com/NYULibraries/nyulibraries_javascripts', tag: 'v1.0.0'
gem 'nyulibraries_errors', git: 'https://github.com/NYULibraries/nyulibraries_errors', tag: 'v1.0.1'
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
  gem 'rspec-rails', '~> 3.5'
  gem 'rspec-its'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'phantomjs', '>= 1.9.0'
  gem 'poltergeist', '~> 1.10.0'
  gem 'selenium-webdriver'
  gem 'elasticsearch-extensions'
end
