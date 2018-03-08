require 'simplecov'
require 'simplecov-rcov'
require 'coveralls'
SimpleCov.merge_timeout 3600
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'rspec/its'

require 'rake'
require 'elasticsearch/extensions/test/cluster/tasks'
require 'devise'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include FactoryBot::Syntax::Methods

  # Include helpers for JSON
  config.include JsonSpec::Helpers

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :helper

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  ES_CLASSES = [Room, Reservation]
  config.before :suite do
    unless ENV['ROOMS_DEV_ELASTICSEARCH_URL'] == 'http://elasticsearch:9200'
      Elasticsearch::Extensions::Test::Cluster.start(port: 9200) unless Elasticsearch::Extensions::Test::Cluster.running?
    end
    ES_CLASSES.each do |esc|
      esc.__elasticsearch__.create_index! force: true
    end
  end

  config.after :suite  do
    ES_CLASSES.each do |esc|
     esc.__elasticsearch__.client.indices.delete index: esc.index_name
    end
    unless ENV['ROOMS_DEV_ELASTICSEARCH_URL'] == 'http://elasticsearch:9200'
      Elasticsearch::Extensions::Test::Cluster.stop(port: 9200)
    end
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
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
