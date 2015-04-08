source 'https://rubygems.org'

gem 'rails', '~> 4.1.9'

gem 'mysql2', '~> 0.3.17'

gem 'coffee-rails', '~> 4.1.0'
gem 'uglifier', '~> 2.5.3'
gem 'therubyracer', '~> 0.12.1'
gem 'compass-rails', '~> 2.0.0'
gem 'yui-compressor', '~> 0.12.0'
gem 'temporal-rails', '~> 0.2.3'
gem 'sass-rails', '~> 5.0.1'
gem 'json', '~> 1.8.1'
gem 'jquery-rails', '~> 3.1.2'
gem 'jquery-ui-rails', '~> 4.2.1'
gem 'cancancan', '~> 1.10.1'
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

gem 'exlibris-aleph', github: 'barnabyalter/exlibris-aleph'
gem 'authpds', github: 'barnabyalter/authpds'
gem 'authpds-nyu', github: 'barnabyalter/authpds-nyu'
gem 'nyulibraries-assets', github: 'NYULibraries/nyulibraries-assets', tag: 'v4.2.1'
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
