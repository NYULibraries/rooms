require 'test_helper'

class BlocksControllerTest < ActionController::TestCase

  setup do
    activate_authlogic
    current_user = UserSession.create(users(:admin))
  end
  
  test "should get index" do
    get :index
    assert assigns(:rooms)
    assert assigns(:blocks)
    assert_response :success
    assert_template :index
  end
  
  test "should get new" do
    get :new
    assert assigns(:block)
    assert_response :success
    assert_template :new
  end
  
  #test "should get create" do
  #  assert_difference('Reservation.count', 1) do
  #    post :create, :reservation => {:end_dt => "2012-11-01 00:00", :start_dt => "2012-10-01 00:00"}
  #  end
  #  assert assigns(:block)
  #  assert_equal assigns(:block).title, I18n.t('blocks.default_title')
  #  assert_response :success
  #end
  
  #test "should destroy multiple" do
  #  put :destroy_multiple
  #  assert_response :success
  #end
  #
  #test "should destroy" do
  #  get :destroy
  #  assert_response :success
  #end
  #
  #test "should get existing reservations" do
  #  get :existing_reservations
  #  assert_response :success
  #end

end