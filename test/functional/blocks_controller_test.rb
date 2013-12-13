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
  
  test "should create" do
    VCR.use_cassette("block create") do
      assert_difference('Reservation.count', 1) do
        post :create, :reservation => {:room_id => 3, :end_dt => "2012-11-01 00:00", :start_dt => "2012-10-01 00:00"}
      end
    end
    assert assigns(:block)
    assert_equal assigns(:block).title, I18n.t('blocks.default_title')
    assert_redirected_to blocks_url
  end
  
  test "should destroy" do
    VCR.use_cassette("block destroy") do
      assert_difference('Reservation.count', -1) do
        delete :destroy, :id => reservations(:block)
      end
    end
    assert assigns(:block)
    assert_equal flash[:notice], I18n.t('blocks.destroy.success')
    assert_redirected_to blocks_url
  end
  
  test "should render destroy existing reservations" do
    VCR.use_cassette("block cannot create until delete existing") do
      post :create, :reservation => {:room_id => 1, :start_dt => "3020-04-01 00:00", :end_dt => "3020-06-01 00:00"}
      assert assigns(:block).invalid?
      assert !assigns(:block).errors.empty?
      assert_template :new

      post :destroy_existing_reservations, :reservation => {:room_id => 1, :start_dt => "3020-04-01 00:00", :end_dt => "3020-06-01 00:00"}, :cancel => "delete_with_alert", :reservations_to_delete => [9,10]
      assert_equal flash[:notice], I18n.t('blocks.destroy_existing_reservations.success')
      assert_redirected_to blocks_url
    end
  end
  
  test "should get existing reservations" do
    get :index_existing_reservations, :reservations_to_delete => [9,10]
    assert assigns(:existing_reservations)
    assert_equal assigns(:existing_reservations).count, 2
    assert_template :index_existing_reservations
  end

end