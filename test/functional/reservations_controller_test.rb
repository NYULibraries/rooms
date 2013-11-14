require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase

  setup do
    activate_authlogic
    current_user = UserSession.create(users(:undergraduate))
  end
  
  test "reservations main page" do
    VCR.use_cassette('reservations index') do
      get :index
      assert assigns(:user)
      assert assigns(:reservation)
      assert assigns(:reservations)
      assert_equal assigns(:user), users(:undergraduate)
    end
  end
  
  test "reservations index with forced time" do
    #Timecop.freeze(Time.local(2030, 9, 1, 11, 29, 0)) do
    #  get :index
    #  assert_select "#reservation_hour option[selected='selected']", "11"
    #  assert_select "#reservation_minute option[selected='selected']", "30"
    #  assert_select "#reservation_ampm option[selected='selected']", "am"
    #end
    #Timecop.freeze(Time.local(2030, 9, 1, 11, 34, 0)) do
    #  get :index
    #  assert_select "#reservation_hour option[selected='selected']", "12"
    #  assert_select "#reservation_minute option[selected='selected']", "00"
    #  assert_select "#reservation_ampm option[selected='selected']", "pm"
    #end
    #Timecop.freeze(Time.local(2030, 9, 1, 12, 34, 0)) do
    #  get :index
    #  assert_select "#reservation_hour option[selected='selected']", "1"
    #  assert_select "#reservation_minute option[selected='selected']", "00"
    #  assert_select "#reservation_ampm option[selected='selected']", "pm"
    #end
    #Timecop.return
  end
  
  test "get edit action" do
    VCR.use_cassette('reservations get edit page') do
      get :edit, :id => reservations(:undergraduate).to_param
      assert assigns(:user)
      assert assigns(:reservation)
      assert_template :edit
    end
  end
  
  test "update reservation" do
    VCR.use_cassette('reservations update reservation') do
      put :update, :id => reservations(:undergraduate).to_param, :reservation => { :title => "What a class this will be!" }
      assert assigns(:user)
      assert assigns(:reservation)
      assert_equal Reservation.find(reservations(:undergraduate).to_param).title, "What a class this will be!"
      assert_redirected_to root_url
    end
  end
  
  test "get new action" do
    current_user = UserSession.create(users(:hasnt_been_used_grad))
    VCR.use_cassette('reservations get new page') do
     get :new, :reservation => { :start_dt => '3020-01-01 11:30:00'.to_time, :end_dt => '3020-01-01 11:30:00'.to_time + 60.minutes }
     assert assigns(:user)
     assert assigns(:reservation)
     assert_template :new
    end
  end
  
  test "fail with invalid date" do
    current_user = UserSession.create(users(:hasnt_been_used_grad))
    VCR.use_cassette('reservations fail with invalid date') do
     get :new, :reservation => { :which_date => "blah", :hour => "1", :minute => "00", :ampm => "pm", :how_long => 300 } 
     assert_equal flash[:error], I18n.t('reservation.date_formatted_correctly')
    end
  end
  
  #test "already created reservation today" do
  #  current_user = UserSession.create(users(:no_bookings_undergrad))
  #  VCR.use_cassette('reservations already created today') do
  #    #assert_difference('Reservation.count', 1) do
  #    #  post :create, :reservation => { :room_id => rooms(:collaborative).to_param, :start_dt => Time.now, :end_dt => Time.now + 60.minutes, :cc => "silly@dummy.org" }
  #    #end
  #    get :new, :reservation => { :start_dt => Time.now, :end_dt => Time.now + 60.minutes }  
  #    assert assigns(:user)
  #    assert assigns(:reservation)
  #    assert_template "user_sessions/unauthorized_action"
  #    assert_equal flash[:error], I18n.t('unauthorized.made_today.reservation')
  #    #assert_difference('Reservation.count', -1) do
  #    #  Reservation.find(assigns(:reservation).to_param).destroy
  #    #end
  #  end
  #end
  
  test "already created reservation for day" do
    current_user = UserSession.create(users(:hasnt_been_used_undergrad))
    VCR.use_cassette('reservations created for same day') do
     get :new, :reservation => { :start_dt => reservations(:for_different_day).start_dt, :end_dt => reservations(:for_different_day).start_dt + 60.minutes }
     assert assigns(:user)
     assert assigns(:reservation)
     assert_template "user_sessions/unauthorized_action"
     assert_equal flash[:error], I18n.t('unauthorized.create_for_same_day.reservation')
    end
  end
  
  test "invalid length of time grad" do
    current_user = UserSession.create(users(:hasnt_been_used_grad))
    VCR.use_cassette('invalid length of time for grad') do
     get :new, :reservation => { :which_date => Time.now.strftime("%Y/%m/%d"), :hour => "1", :minute => "00", :ampm => "pm", :how_long => 300 }  
     assert assigns(:user)
     assert assigns(:reservation)
     assert_template "user_sessions/unauthorized_action"
     assert_equal flash[:error], I18n.t('unauthorized.create_for_length.reservation')
    end
  end
  
  test "invalid length of time undergrad" do
    current_user = UserSession.create(users(:hasnt_been_used_undergrad))
    VCR.use_cassette('invalid length of time for undergrad') do
     get :new, :reservation => { :which_date => Time.now.strftime("%Y/%m/%d"), :hour => "1", :minute => "00", :ampm => "pm", :how_long => 150 }    
     assert assigns(:user)
     assert assigns(:reservation)
     assert_template "user_sessions/unauthorized_action"
     assert_equal flash[:error], I18n.t('unauthorized.create_for_length.reservation')
    end
  end
  
  test "array of emails in cc" do
    current_user = UserSession.create(users(:admin))
    VCR.use_cassette('reservations cant create with invalid ccs') do
      assert_no_difference('Reservation.count', 1) do
        post :create, :reservation => { :room_id => rooms(:collaborative).to_param, :start_dt => Time.now, :end_dt => Time.now + 150.minutes, :cc => "dummy@silly.org, mr.invalid.in.array" }  
      end
      assert assigns(:reservation).invalid?
      assert_equal assigns(:reservation).errors.full_messages.first, I18n.t('reservation.validate_cc')
      assert_no_difference('Reservation.count', 1) do
        post :create, :reservation => { :room_id => rooms(:collaborative).to_param, :start_dt => Time.now, :end_dt => Time.now + 150.minutes }  
      end
      assert assigns(:reservation).invalid?
      assert_equal assigns(:reservation).errors.full_messages.first, I18n.t('reservation.collaborative_requires_ccs')
      assert_no_difference('Reservation.count', 1) do
        post :create, :reservation => { :room_id => rooms(:collaborative).to_param, :start_dt => Time.now, :end_dt => Time.now + 150.minutes, :cc => "mr.invalid" }  
      end
      assert assigns(:reservation).invalid?
      assert_equal assigns(:reservation).errors.full_messages.first, I18n.t('reservation.validate_cc')
      assert_no_difference('Reservation.count', 1) do
        post :create, :reservation => { :room_id => rooms(:collaborative).to_param, :start_dt => Time.now, :end_dt => Time.now + 150.minutes, :cc => "admin@university.edu" }  
      end
      assert assigns(:reservation).invalid?
      assert_equal assigns(:reservation).errors.full_messages.first, I18n.t('reservation.current_user_is_only_email')
    end
  end
  
  test "create new reservation grad" do
    current_user = UserSession.create(users(:no_bookings_grad))
    VCR.use_cassette('reservations create new gradute') do
      assert_difference('Reservation.count', 1) do
        post :create, :reservation => { :room_id => rooms(:collaborative).to_param, :start_dt => '3020-03-01 11:30:00'.to_time + 2.days, :end_dt => '3020-03-01 11:30:00'.to_time + 2.days + 150.minutes, :cc => "dummy@silly.org" }  
      end
      assert assigns(:user)
      assert assigns(:reservation)
      assert_response :success
      assert_template :index
      assert_difference('Reservation.count', -1) do
        Reservation.find(assigns(:reservation).to_param).destroy
      end
    end
  end
  
  #test "create new reservation undergrad" do
  #  current_user = UserSession.create(users(:no_bookings_undergrad))
  #  VCR.use_cassette('reservations create new undergraduate') do
  #    assert_difference('Reservation.count', 1) do
  #      post :create, :reservation => { :id => 11, :room_id => rooms(:collaborative).id, :start_dt => Time.now + 2.days, :end_dt => Time.now + 2.days + 30.minutes, :cc => "dummy@silly.org" }  
  #    end
  #    assert assigns(:user)
  #    assert assigns(:reservation)
  #    assert_response :success
  #    assert_template :index
  #    assert_difference('Reservation.count', -1) do
  #      Reservation.find(assigns(:reservation).to_param).destroy
  #    end
  #  end
  #end
  
  test "deletes existing reservation" do
    current_user = UserSession.create(users(:undergraduate))
    VCR.use_cassette("reservation delete existing") do
      put :delete, :reservation_id => reservations(:undergraduate).id
    end
    assert assigns(:user)
    assert assigns(:reservation)
    assert_equal flash[:success], I18n.t('reservations.delete.success')
  end
  
  test "can't delete existing reservation if not own" do
    
  end
  
  test "can't update existing reservation if not own" do
    
  end
  
  test "resend mail action" do
    current_user = UserSession.create(users(:admin))
    get :resend_email, :id => reservations(:admin_res).id
    assert assigns(:user)
    assert assigns(:reservation)
    assert_equal flash[:success], I18n.t('reservations.resend_email.success')
    assert_template :resend_email
  end
  
end