require 'test_helper'
require 'rails/performance_test_help'

class HomepageTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  #setup do
  #
  #  current_user = UserSession.create(users(:admin))
  #end

  def test_homepage
   get '/'
  end

  test "availability grid" do
   get '/reservations/new?reservation%5Bwhich_date%5D=2013-11-16&reservation%5Bhour%5D=12&reservation%5Bminute%5D=30&reservation%5Bampm%5D=pm&reservation%5Bhow_long%5D=180'
  end
end
