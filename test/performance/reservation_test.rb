require 'test_helper'
require 'rails/performance_test_help'
 
class ReservationTest < ActionDispatch::PerformanceTest
  setup do
    activate_authlogic
    current_user = UserSession.create(users(:admin))
  end
 
  def test_getting_availabilty_grid
    get '/reservations/new?reservation%5Bwhich_date%5D=2013-11-01&reservation%5Bhour%5D=4&reservation%5Bminute%5D=0&reservation%5Bampm%5D=pm&reservation%5Bhow_long%5D=180'
  end
end