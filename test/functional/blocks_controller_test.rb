require 'test_helper'

class BlocksControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in FactoryGirl.create(:admin)
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
    assert_difference('Reservation.count', 1) do
      post :create, :reservation => {:room_id => 3, :end_dt => "2012-11-01 00:00", :start_dt => "2012-10-01 00:00"}
    end
    assert assigns(:block)
    assert_equal assigns(:block).title, I18n.t('blocks.default_title')
    assert_redirected_to blocks_url
  end

  test "should destroy" do
    reservation = FactoryGirl.create(:reservation)
    assert_difference('Reservation.count', -1) do
      delete :destroy, :id => reservation
    end
    assert assigns(:block)
    assert_equal flash[:notice], I18n.t('blocks.destroy.success')
    assert_redirected_to blocks_url
  end

  test "should render destroy existing reservations" do
    existing_reservation = FactoryGirl.create(:reservation)
    wait_for_tire_index
    post :create, reservation: { room_id: existing_reservation.room_id, start_dt: existing_reservation.start_dt, end_dt: existing_reservation.end_dt }
    assert assigns(:block).invalid?
    assert !assigns(:block).errors.empty?
    assert_template :new
    post :destroy_existing_reservations, reservation: { room_id: existing_reservation.room_id, start_dt: existing_reservation.start_dt, end_dt: existing_reservation.end_dt }, :cancel => "delete_with_alert", :reservations_to_delete => [existing_reservation.id]
    assert_equal flash[:notice], I18n.t('blocks.destroy_existing_reservations.success')
    assert_redirected_to blocks_url
  end

  test "should get existing reservations" do
    test_reservation_one    = FactoryGirl.create(:reservation)
    test_reservation_two    = FactoryGirl.create(:reservation)
    test_reservation_three  = FactoryGirl.create(:reservation)
    test_reservation_four   = FactoryGirl.create(:reservation)
    get :index_existing_reservations, :reservations_to_delete => [test_reservation_one.id,test_reservation_two.id]
    assert assigns(:existing_reservations)
    assert_equal assigns(:existing_reservations).count, 2
    assert_template :index_existing_reservations
  end

end
