require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase

  setup do
    activate_authlogic
    current_user = UserSession.create(users(:admin))
  end

  test "validate redirects correctly" do
    get :validate
    assert_redirected_to root_url
  end
end