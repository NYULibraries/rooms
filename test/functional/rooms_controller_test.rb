require 'test_helper'

class RoomsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in FactoryGirl.create(:admin)
  end

  test "gets index of rooms" do
    get :index
    assert assigns(:rooms)
    assert_template :index
  end

  test "gets index of ny rooms" do
    @request.env["devise.mapping"] = Devise.mappings[:ny_admin]
    sign_in FactoryGirl.create(:ny_admin)
    get :index
    assert assigns(:rooms)
    assert_template :index
  end

  test "gets index of rooms with search results" do
    FactoryGirl.create(:room, image_link: "google.com")
    wait_for_tire_index
    get :index, :q => "google.com"
    assert assigns(:rooms)
    assert_equal assigns(:rooms).count, 1
    assert_template :index
  end

  test "get show action" do
    get :show, :id => FactoryGirl.create(:room)
    assert assigns(:room)
    assert_template :show
  end

  test "get new action" do
    get :new
    assert assigns(:room)
    assert_template :new
  end

  test "create new room" do
    assert_difference('Room.count', 1) do
      post :create, :room => { :room_group_id => FactoryGirl.create(:room_group).to_param, :title => "Cool new room" }, :opens_at => { :hour => '7', :minute => '0', :ampm => 'am'}, :closes_at => { :hour => '7', :minute => '0', :ampm => 'am'}
    end
    assert assigns(:room)
    assert_redirected_to room_url(assigns(:room))
    assert_difference('Room.count', -1) do
      delete :destroy, :id => assigns(:room).id
    end
  end

  test "get edit action" do
    get :edit, :id => FactoryGirl.create(:room)
    assert assigns(:room)
    assert_template :edit
  end

  test "update room" do
    room = FactoryGirl.create(:room)
    put(:update, :id => room, :room => {:title => "Changing Titles"}, :opens_at => { :hour => '7', :minute => '0', :ampm => 'am'}, :closes_at => { :hour => '7', :minute => '0', :ampm => 'am'})

    assert_equal flash[:notice], I18n.t("rooms.update.success")
    assert_equal Room.find(room).title, "Changing Titles"
    assert_redirected_to room_path(room)
  end

  test "deletes room" do
    room = FactoryGirl.create(:room)
    assert_difference('Room.count', -1) do
      delete :destroy, :id => room
    end
    assert assigns(:room)
    assert_redirected_to rooms_url
  end

  test "gets sort index of rooms" do
    get :index_sort
    assert assigns(:rooms)
    assert_template :index_sort
  end

  test "updates order of rooms" do
    room_one    = FactoryGirl.create(:room)
    room_two    = FactoryGirl.create(:room)
    room_three  = FactoryGirl.create(:room)
    put :update_sort, :rooms => [room_three,room_two,room_one]
    assert_equal flash[:notice], I18n.t("rooms.update_sort.success")
    assert_redirected_to sort_rooms_url
    assert_equal Room.find(room_three).sort_order, 1
    assert_equal Room.find(room_two).sort_order, 2
    assert_equal Room.find(room_one).sort_order, 3
  end

end
