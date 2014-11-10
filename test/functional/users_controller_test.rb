require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in FactoryGirl.create(:admin)
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
    get :show, :id => FactoryGirl.create(:admin)
    assert assigns(:user)
    assert_template :show
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
    assert assigns(:user)
    assert_redirected_to user_url(assigns(:user))
  end

  test "get edit action" do
    get :edit, :id => FactoryGirl.create(:admin)
    assert assigns(:user)
    assert_template :edit
  end

  test "update existing user" do
    nonadmin = FactoryGirl.create(:user)
    assert !nonadmin.is_admin?

    put :update, :id => nonadmin, :user => { :admin_roles => ["superuser"] }

    assert_equal flash[:notice], I18n.t('users.update.success')
    assert User.find(nonadmin.to_param).is_admin?
    assert_redirected_to user_url(nonadmin)
  end

  test "destroy user" do
    user = FactoryGirl.create(:user)
    assert_difference('User.count', -1) do
      delete :destroy, :id => user.to_param
    end

    assert assigns(:user)
    assert_redirected_to users_url
  end


end
