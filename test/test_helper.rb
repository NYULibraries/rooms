ENV["RAILS_ENV"] ||= "test"

unless ENV['TRAVIS']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
else
  require 'coveralls'
  Coveralls.wear!
end

require 'vcr'
require 'webmock'
WebMock.allow_net_connect!

VCR.configure do |c|
  #c.ignore_hosts '127.0.0.1', 'localhost'
  c.cassette_library_dir = 'test/vcr_cassettes'
  # webmock needed for HTTPClient testing
  c.hook_into :webmock 
  #c.filter_sensitive_data("http://localhost:9200") { "" }
end

VCR.use_cassette('load elasticsearch models') do
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
  fixtures :all
  
  def set_dummy_pds_user(user_session)
    user_session.instance_variable_set("@pds_user".to_sym, users(:real_user))
  end
  
  VCR.use_cassette('reindex models') do
    Reservation.index.delete
    Reservation.index.import Reservation.all
  
    Room.index.delete
    Room.index.import Room.all
  end

  
end

