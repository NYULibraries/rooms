require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase

  setup do
    activate_authlogic
    current_user = UserSession.create(users(:undergraduate))
  end
  
end