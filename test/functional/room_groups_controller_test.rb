require 'test_helper'

class RoomGroupsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in FactoryGirl.create(:admin)
  end

  test "should get index" do
    get :index
    assert assigns(:room_groups)
    assert_response :success
  end

  test "should get show" do
    get :show, :id => FactoryGirl.create(:room_group)
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
    assert_redirected_to(room_group_path(assigns(:room_group)))
  end

  test "should get edit" do
    get :edit, :id => FactoryGirl.create(:room_group)
    assert assigns(:room_group)
    assert_template :edit
  end

  test "should get update" do
    room_group = FactoryGirl.create(:room_group)
    put :update, :id => room_group, :room_group => {:title => "Jeepers Creepers"}
    assert assigns(:room_group)
    assert_equal RoomGroup.find(room_group).title, "Jeepers Creepers"
    assert_redirected_to (room_group_path(assigns(:room_group)))
  end

  test "should get destroy" do
    existing_room_group = FactoryGirl.create(:room_group)
    assert_difference('RoomGroup.count', -1) do
      delete :destroy, :id => existing_room_group
    end
    assert assigns(:room_group)
    assert_redirected_to room_groups_url
  end

end
