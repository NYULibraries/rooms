require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  setup do
    activate_authlogic
    current_user = UserSession.create(users(:admin))
  end
  
end