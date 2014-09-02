source 'https://rubygems.org'

gem 'rails', '~> 3.2.18'

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

gem 'json', '~> 1.8.0'
gem 'jquery-rails', '~> 3.1.0'
gem 'jquery-ui-rails', '~> 4.2.0'
gem 'cancan', '~> 1.6.10'
gem 'kaminari', '~> 0.13'
gem 'sorted', '~> 0.4.3'
gem 'acts_as_indexed', '~> 0.8.3'
gem 'mustache', '0.99.4'
gem 'mustache-rails', git: 'git://github.com/josh/mustache-rails.git', :require => 'mustache/railtie'
gem 'dalli', '~> 2.7.0'
gem 'comma', '~> 3.2.0'
gem 'tire', '~> 0.6.2' # Doesn't officially support ElasticSearch 1.x
gem 'draper', '~> 1.3.0'

gem 'newrelic_rpm', '~> 3.8.0'

gem 'authpds-nyu', :git => 'git://github.com/NYULibraries/authpds-nyu.git', :tag => 'v1.1.2'
gem 'nyulibraries-assets', :git => 'git://github.com/NYULibraries/nyulibraries-assets.git', :tag => 'v2.1.1'
gem 'nyulibraries-deploy', :git => 'git://github.com/NYULibraries/nyulibraries-deploy.git', :tag => 'v4.0.0'
gem 'rails_config', '~> 0.3.3'

group :development do
  gem 'progress_bar'
end

group :test do
  #Testing coverage
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'coveralls', '~> 0.7.0', :require => false
  gem 'vcr', '~> 2.8.0'
  gem 'webmock', '>= 1.8.0', '< 1.16'
  gem 'timecop', '~> 0.6.3'
  gem 'ruby-prof', '~> 0.15.1'
  gem 'rspec-rails', '~> 2.14.0'
  # Use factory girl for creating models
  gem 'factory_girl_rails', '~> 4.4.0'
  # Use pry-debugger as the REPL and for debugging
  gem 'pry-debugger', '~> 0.2.2'
  gem 'pry-remote', '~> 0.1.8'
end
