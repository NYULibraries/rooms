require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase

  setup do
    activate_authlogic
    current_user = UserSession.create(users(:admin))
  end
  
  test "reservations main page" do
    VCR.use_cassette('reservations index') do
      get :index
      assert assigns(:user)
      assert assigns(:reservation)
      assert assigns(:reservations)
      assert_equal assigns(:user), users(:admin)
    end
  end
  
  test "get edit action" do
    VCR.use_cassette('reservations get edit page') do
      get :edit, :id => reservations(:one)
      assert assigns(:user)
      assert assigns(:reservation)
      assert_template :edit
    end
  end
  
  test "update reservation" do
    
  end
  
  test "get new action" do
    
  end
  
  test "already created reservation today" do
    
  end
  
  test "already created reservation for today" do

  end
  
  test "create new reservation" do
    
  end
  
  test "deletes existing reservation" do
    
  end
  
  test "resend mail action" do
    
  end
  
end