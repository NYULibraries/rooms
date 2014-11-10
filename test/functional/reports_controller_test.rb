require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in FactoryGirl.create(:admin)
    @reservation = FactoryGirl.create(:reservation)
  end

  test "get report index" do
    get :index
    assert_template :index
  end

  test "generate basic report" do
    get :index, :report => {:start_dt => "2013-10-01 10:00", :end_dt => "2013-11-01 10:00"}
    assert assigns(:reservations)
    assert assigns(:start_dt)
    assert assigns(:end_dt)
    assert_equal flash[:error], "Could not find any data for the range you selected."
    assert_template :index
  end
  
  test "generate basic report in CSV" do
    get :index, :report => {:start_dt => "3020-10-01 10:00", :end_dt => "3020-11-01 10:00"}, :format => :csv
    assert assigns(:reservations)
    assert assigns(:start_dt)
    assert assigns(:end_dt)
    assert flash[:error].blank?
    assert_response :success
  end
  
  test "report with invalid dates" do
    get :index, :report => {:start_dt => "2013-11-01 10:00", :end_dt => "2013-10-01 10:00"}
    assert_equal flash[:error], "Please select a valid end date that is after your selected start date."
    assert_template :index
  end
  
  test "report with invalid dates formats" do
    get :index, :report => {:start_dt => "10:00 2013-01-01", :end_dt => "12:00 2013-03-01"}
    assert_equal flash[:error], "Please select a valid date and time in the format YYYY-MM-DD HH:MM for start and end fields. Note that minutes must be either 00 or 30."
    assert_template :index
  end
  
end