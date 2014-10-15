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
  require 'vcr'
  require 'webmock'
  WebMock.allow_net_connect!

  VCR.configure do |c|
    c.default_cassette_options = { allow_playback_repeats: true, record: :once }
    #c.ignore_hosts '127.0.0.1', 'localhost'
    c.cassette_library_dir = 'test/vcr_cassettes'
    # webmock needed for HTTPClient testing
    c.hook_into :webmock
    #c.filter_sensitive_data("http://localhost:9200") { ENV['ROOMS_BONSAI_URL'] }

    # Register a custom request matcher to ignore trailing path ID
    # => POST /rooms/1 will match POST /rooms
    # Pulled from http://railsware.com/blog/2013/10/03/custom-vcr-matchers-for-dealing-with-mutable-http-requests/
    c.register_request_matcher :uri_ignoring_trailing_id do |request_1, request_2|
      uri1, uri2 = request_1.uri, request_2.uri
      regexp_trail_id = %r(/\d+/?\z)
      if uri1.match(regexp_trail_id)
        r1_without_id = uri1.gsub(regexp_trail_id, "")
        r2_without_id = uri2.gsub(regexp_trail_id, "")
        uri1.match(regexp_trail_id) && uri2.match(regexp_trail_id) && r1_without_id == r2_without_id
      else
        uri1 == uri2
      end
    end
  end

  VCR.use_cassette('load elasticsearch models') do
    require File.expand_path('../../config/environment', __FILE__)
  end
else
  require File.expand_path('../../config/environment', __FILE__)
end

require 'rails/test_help'
require 'authlogic'
require 'authlogic/test_case'

class User
  def nyuidn
    user_attributes[:nyuidn]
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

  #VCR.use_cassette('reindex models') do
  #  Reservation.index.delete
  #  Reservation.index.import Reservation.all
  #
  #  Room.index.delete
  #  Room.index.import Room.all
  #end
  #

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
