require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup do
    activate_authlogic
    current_user = UserSession.create(users(:admin))
  end

  test "gets user index" do
    get :index
    assert assigns(:users)

    assert_template :index
  end

  test "gets user index as csv" do
    get :index, :format => :csv
    assert assigns(:users)
  end

  test "get show action" do
    VCR.use_cassette('get users reservations in show action') do
      get :show, :id => users(:admin)
      assert assigns(:user)
      assert_template :show
    end
  end

  test "get new action" do
    get :new
    assert assigns(:user)
    assert_template :new
  end

  test "create new user" do
    assert_difference('User.count', 1) do
      post :create, :user => { :username => "abc12", :email => "barney@dinosaur.org" }
    end
    assert User.find_by_username("abc12")
    assert assigns(:user)
    assert_redirected_to user_url(assigns(:user))
  end

  test "get edit action" do
    get :edit, :id => users(:admin)
    assert assigns(:user)
    assert_template :edit
  end

  test "update existing user" do
    assert !users(:nonadmin).is_admin?

    put :update, :id => users(:nonadmin), :user => { :admin_roles => ["superuser"] }

    assert_equal flash[:notice], I18n.t('users.update.success')
    assert User.find(users(:nonadmin).to_param).is_admin?
    assert_redirected_to user_url(users(:nonadmin))
  end

  test "destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:delete_me).to_param
    end

    assert assigns(:user)
    assert_redirected_to users_url
  end


end
