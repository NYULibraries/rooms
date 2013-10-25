require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase

  setup do
    activate_authlogic
    current_user = UserSession.create(users(:undergraduate))
  end
  
  test "reservations main page" do
    VCR.use_cassette('reservations index') do
      get :index
      assert assigns(:user)
      assert assigns(:reservation)
      assert assigns(:reservations)
      assert_equal assigns(:user), users(:undergraduate)
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
    VCR.use_cassette('reservations update reservation') do
      put :update, :id => reservations(:one), :reservation => { :title => "What a class this will be!" }
      assert assigns(:user)
      assert assigns(:reservation)
      assert_equal Reservation.find(reservations(:one).to_param).title, "What a class this will be!"
      assert_redirected_to root_url
    end
  end
  
  test "get new action" do
    VCR.use_cassette('reservations get new page') do
     get :new, :reservation => { :start_dt => Time.now, :end_dt => Time.now + 60.minutes}
     #assert assigns(:user)
     #assert assigns(:reservation)
     #assert_template :new
    end
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