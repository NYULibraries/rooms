require 'simplecov'
require 'simplecov-rcov'
require 'coveralls'
SimpleCov.merge_timeout 3600
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

ENV["RAILS_ENV"] ||= 'test'

if ENV["RAILS_ENV"] == "test"
  require File.expand_path('../../config/environment', __FILE__)
end
require 'rspec/rails'
require 'rspec/autorun'


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include FactoryGirl::Syntax::Methods
  # config.before(:suite) do
  #   DatabaseCleaner.strategy = :transaction
  #   DatabaseCleaner.clean_with(:truncation)
  # end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

ENV['INSTITUTIONS'] = <<YAML
---
NYU:
  ip_addresses:
    - 127.0.0.1
NYUAD:
  ip_addresses:
    - 127.0.0.1
NYUSH:
  ip_addresses:
    - 127.0.0.1
NYSID:
  ip_addresses:
    - 127.0.0.1
HSL:
  ip_addresses:
    - 127.0.0.1
CU:
  ip_addresses:
    - 127.0.0.1
NS:
  ip_addresses:
    - 127.0.0.1
YAML
ENV['ROOMS_ROLES_ADMIN'] = <<YAML
---
- superuser
- ny_admin
- shanghai_admin
YAML
ENV['ROOMS_DEFAULT_ADMINS'] = <<YAML
---
- admin
YAML
ENV['ROOMS_ROLES_AUTHORIZED'] = <<YAML
---
shanghai_undergraduate:
  - '0'
ny_undergraduate:
  - '1'
  - '2'
ny_graduate:
  - '3'
  - '4'
  - '5'
  - '6'
  - '7'
YAML
