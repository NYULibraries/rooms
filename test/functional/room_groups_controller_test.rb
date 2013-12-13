require 'test_helper'

class RoomGroupsControllerTest < ActionController::TestCase
  
  setup do
    activate_authlogic
    current_user = UserSession.create(users(:admin))
  end
  
  test "should get index" do
    get :index
    assert assigns(:room_groups)
    assert_response :success
  end
  
  test "should get show" do
    get :show, :id => room_groups(:one)
    assert assigns(:room_group)
    assert_template :show
  end
  
  test "should get new" do
    get :new
    assert assigns(:room_group)
    assert_response :success
  end
  
  test "should get create" do
    assert_difference('RoomGroup.count', 1) do
      post :create, :room_group => { :title => "Grouper Grouper", :code => "jeepers", :admin_roles => ["global"] }
    end
    assert assigns(:room_group)
    assert_redirected_to room_group_path(assigns(:room_group))
  end
  
  test "should get edit" do
    get :edit, :id => room_groups(:one)
    assert assigns(:room_group)
    assert_template :edit
  end
  
  test "should get update" do
    put :update, :id => room_groups(:one), :room_group => {:title => "Jeepers Creepers"}
    assert assigns(:room_group)
    assert_equal RoomGroup.find(room_groups(:one)).title, "Jeepers Creepers"
    assert_redirected_to room_group_path(assigns(:room_group))
  end
  
  test "should get destroy" do
    VCR.use_cassette('destory room group with dependent rooms') do
      assert_difference('RoomGroup.count', -1) do
        delete :destroy, :id => room_groups(:delete_three)
      end
      assert assigns(:room_group)
      assert_redirected_to room_groups_url
    end
  end

end