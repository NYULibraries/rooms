require 'test_helper'

class RoomsControllerTest < ActionController::TestCase

  setup do
    activate_authlogic
    current_user = UserSession.create(users(:admin))
  end
  
  test "gets index of rooms" do
    VCR.use_cassette('rooms index') do
      get :index
      assert assigns(:rooms)
      assert_template :index
    end
  end
  
  test "gets index of ny rooms" do
    current_user = UserSession.create(users(:ny_admin))
    VCR.use_cassette('rooms ny index') do
      get :index
      assert assigns(:rooms)
      assert_template :index
    end
  end
  
  test "gets index of rooms with search results" do
    VCR.use_cassette('search rooms') do
      get :index, :q => "google.com"
      assert assigns(:rooms)
      assert_equal assigns(:rooms).count, 1
      assert_template :index
    end
  end
  
  test "get show action" do
    get :show, :id => rooms(:individual)
    assert assigns(:room)
    assert_template :show
  end
  
  test "get new action" do
    get :new
    assert assigns(:room)
    assert_template :new
  end
  
  test "create new room" do
    VCR.use_cassette('create new room') do
      assert_difference('Room.count', 1) do
        post :create, :room => { :room_group_id => room_groups(:one).to_param, :title => "Cool new room" }, :opens_at => { :hour => '7', :minute => '0', :ampm => 'am'}, :closes_at => { :hour => '7', :minute => '0', :ampm => 'am'} 
      end
      assert assigns(:room)
      assert_redirected_to room_url(assigns(:room))
      assert_difference('Room.count', -1) do
        delete :destroy, :id => assigns(:room).id
      end
    end
  end
  
  test "get edit action" do
    get :edit, :id => rooms(:individual)
    assert assigns(:room)
    assert_template :edit
  end
  
  test "update room" do
    VCR.use_cassette('update existing room') do
      put :update, :id => rooms(:individual), :room => {:title => "Changing Titles"}, :opens_at => { :hour => '7', :minute => '0', :ampm => 'am'}, :closes_at => { :hour => '7', :minute => '0', :ampm => 'am'} 
    
      assert_equal flash[:notice], I18n.t("rooms.update.success")
      assert_equal Room.find(rooms(:individual)).title, "Changing Titles"
      assert_redirected_to room_path(rooms(:individual))
    end
  end
  
  test "deletes room" do
    VCR.use_cassette('destroy a room') do
      assert_difference('Room.count', -1) do
        delete :destroy, :id => rooms(:individual_with_hours)
      end
      assert assigns(:room)
      assert_redirected_to rooms_url      
    end
  end
  
  test "gets sort index of rooms" do
    get :index_sort
    assert assigns(:rooms)
    assert_template :index_sort
  end
  
  test "updates order of rooms" do
    VCR.use_cassette('reordering rooms') do
      put :update_sort, :rooms => [3,2,1]
      assert_equal flash[:notice], I18n.t("rooms.update_sort.success")
      assert_redirected_to sort_rooms_url
    end
    assert_equal Room.find(3).sort_order, 1
    assert_equal Room.find(2).sort_order, 2
    assert_equal Room.find(1).sort_order, 3
  end
  
end