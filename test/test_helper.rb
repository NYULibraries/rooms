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
  Reservation.destroy_all
  User.destroy_all
  Room.destroy_all
end

require 'rails/test_help'
require 'database_cleaner'

DatabaseCleaner.strategy = :transaction



class User
  def nyuidn
    self.aleph_id
  end

  def error; end

  def uid
    username
  end
end

class ActiveSupport::TestCase
  fixtures :all if ENV["RAILS_ENV"] == "test"

  def set_dummy_pds_user(user_session)
    user_session.instance_variable_set("@pds_user".to_sym, users(:real_user))
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
  include FactoryGirl::Syntax::Methods

  def wait_for_tire_index
    sleep 3
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
