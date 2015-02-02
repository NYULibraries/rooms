source 'https://rubygems.org'

gem 'rails', '~> 3.2.21'

gem 'mysql2', '~> 0.3.17'

# Move this out here to use coffee in views
gem 'coffee-rails', '~> 3.2.2'
gem 'uglifier', '~> 2.5.3'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '~> 0.12.1'

  gem 'compass', '~> 0.12.7'
  gem 'compass-rails', '~> 1.1.7'
  gem 'yui-compressor', '~> 0.12.0'
  gem 'temporal-rails', '~> 0.2.3'
end

gem 'json', '~> 1.8.1'
gem 'jquery-rails', '~> 3.1.2'
gem 'jquery-ui-rails', '~> 4.2.1'
gem 'cancan', '~> 1.6.10'
gem 'kaminari', '~> 0.16.1'
gem 'sorted', '~> 1.0.1'
gem 'acts_as_indexed', '~> 0.8.3'
gem 'mustache', '0.99.4'
gem 'mustache-rails', git: 'git://github.com/josh/mustache-rails.git', :require => 'mustache/railtie'
gem 'dalli', '~> 2.7.2'
gem 'comma', '~> 3.2.2'
gem 'tire', '~> 0.6.2' # Doesn't officially support ElasticSearch 1.x
gem 'draper', '~> 1.4.0'

gem 'newrelic_rpm', '~> 3.9.6.257'

gem 'nyulibraries-assets', github: 'NYULibraries/nyulibraries-assets', tag: 'v2.2.0'
gem 'formaggio', github: "NYULibraries/formaggio", tag: 'v1.4.2'
gem 'omniauth-nyulibraries', github: 'NYULibraries/omniauth-nyulibraries' , tag: "v1.1.2"
gem 'devise'

group :development, :test do
  gem 'pry', '~> 0.10.1'
  gem 'progress_bar'
  # Use factory girl for creating models
  gem 'factory_girl_rails', '~> 4.5.0'
  #Testing coverage
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'coveralls', '~> 0.7.1', :require => false
  gem 'webmock', '>= 1.8.0', '< 1.16'
  gem 'timecop', '~> 0.7.1'
  gem 'ruby-prof', '~> 0.15.2'
  gem 'rspec-rails', '~> 2.99.0'
  gem 'faker'
  gem 'pry-remote', '~> 0.1.8'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'phantomjs', '>= 1.9.0'
  gem 'poltergeist', '~> 1.5.0'
  gem 'selenium-webdriver'
end
