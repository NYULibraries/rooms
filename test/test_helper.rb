unless ENV['TRAVIS']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
else
  require 'coveralls'
  Coveralls.wear!
end

ENV["RAILS_ENV"] ||= "test"

require 'webmock'
WebMock.allow_net_connect!

require File.expand_path('../../config/environment', __FILE__)
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
  
  # Recreate Test indexes
  #[Reservation, Room].each do |klass|
  #  klass.index.delete
  #  klass.create_elasticsearch_index
  #  klass.index.import klass.all
  #  klass.index.refresh
  #end

end

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  # webmock needed for HTTPClient testing
  c.hook_into :webmock 
  #c.filter_sensitive_data("localhost:8981") { @@sunspot_host }
  #c.filter_sensitive_data("/solr") { @@sunspot_path }
end

