require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:undergraduate]
    sign_in FactoryGirl.create(:undergraduate)
  end

  test "reservations main page" do
    @request.env["devise.mapping"] = Devise.mappings[:undergraduate]
    undergraduate = FactoryGirl.create(:undergraduate)
    sign_in undergraduate
    get :index
    assert assigns(:user)
    assert assigns(:reservation)
    assert assigns(:reservations)
    assert_equal assigns(:user), undergraduate
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
    @request.env["devise.mapping"] = Devise.mappings[:undergraduate]
    user = FactoryGirl.create(:undergraduate)
    sign_in user
    room = FactoryGirl.create(:collaborative)
    reservation = FactoryGirl.create(:reservation, user_id: user.id, room_id: room.id, cc: Faker::Internet.email)
    get :edit, :id => reservation.to_param
    assert assigns(:user)
    assert assigns(:reservation)
    assert_template :edit
  end

  test "update reservation" do
    @request.env["devise.mapping"] = Devise.mappings[:undergraduate]
    user = FactoryGirl.create(:undergraduate)
    sign_in user
    room = FactoryGirl.create(:collaborative)
    reservation = FactoryGirl.create(:reservation, user_id: user.id, room_id: room.id, cc: Faker::Internet.email)
    put :update, :id => reservation.to_param, :reservation => { :title => "What a class this will be!" }
    assert assigns(:user)
    assert assigns(:reservation)
    assert_equal Reservation.find(reservation).title, "What a class this will be!"
    assert_redirected_to root_url
  end

  test "get new action" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in FactoryGirl.create(:user)
    get :new, :reservation => { :start_dt => '3020-01-01 11:30:00'.to_time, :end_dt => '3020-01-01 11:30:00'.to_time + 60.minutes }
    assert assigns(:user)
    assert assigns(:reservation)
    assert_template :new
  end

  test "fail with invalid date" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in FactoryGirl.create(:user)
    get :new, :reservation => { :which_date => "blah", :hour => "1", :minute => "00", :ampm => "pm", :how_long => 300 }
    assert_equal flash[:error], I18n.t('reservation.date_formatted_correctly')
  end

  #test "already created reservation today" do
  #  current_user = UserSession.create(users(:no_bookings_undergrad))
  #  VCR.use_cassette('reservations already created today') do
  #    #assert_difference('Reservation.count', 1) do
  #    #  post :create, :reservation => { :room_id => FactoryGirl.create(:collaborative).to_param, :start_dt => Time.now, :end_dt => Time.now + 60.minutes, :cc => "silly@dummy.org" }
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
    @request.env["devise.mapping"] = Devise.mappings[:undergraduate]
    user = FactoryGirl.create(:undergraduate)
    sign_in user
    reservation = FactoryGirl.create(:reservation, user_id: user.id, created_at: Time.now - 24.hours, updated_at: Time.now - 24.hours)
    wait_for_tire_index
    get :new, :reservation => { :start_dt => reservation.start_dt + 2.hours, :end_dt => reservation.start_dt + 2.hours }
    assert assigns(:user)
    assert assigns(:reservation)
    assert_template "user_sessions/unauthorized_action"
    assert_equal flash[:error], I18n.t('unauthorized.create_for_same_day.reservation')
  end

  test "invalid length of time grad" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in FactoryGirl.create(:user)
    get :new, :reservation => { :which_date => Time.now.strftime("%Y/%m/%d"), :hour => "1", :minute => "00", :ampm => "pm", :how_long => 300 }
    assert assigns(:user)
    assert assigns(:reservation)
    assert_template "user_sessions/unauthorized_action"
    assert_equal flash[:error], I18n.t('unauthorized.create_for_length.reservation')
  end

  test "invalid length of time undergrad" do
    @request.env["devise.mapping"] = Devise.mappings[:hasnt_been_used_undergrad]
    sign_in FactoryGirl.create(:hasnt_been_used_undergrad)
    get :new, :reservation => { :which_date => Time.now.strftime("%Y/%m/%d"), :hour => "1", :minute => "00", :ampm => "pm", :how_long => 150 }
    assert assigns(:user)
    assert assigns(:reservation)
    assert_template "user_sessions/unauthorized_action"
    assert_equal flash[:error], I18n.t('unauthorized.create_for_length.reservation')
    # end
  end

  test "array of emails in cc" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    user = FactoryGirl.create(:admin)
    sign_in user
    room = FactoryGirl.create(:collaborative)
    wait_for_tire_index
    assert_no_difference('Reservation.count', 1) do
      post :create, :reservation => { :room_id => room.to_param, :start_dt => Time.now, :end_dt => Time.now + 150.minutes, :cc => "dummy@silly.org, mr.invalid.in.array" }
    end
    assert assigns(:reservation).invalid?
    assert_equal assigns(:reservation).errors.full_messages.first, I18n.t('reservation.validate_cc')

    assert_no_difference('Reservation.count', 1) do
      post :create, :reservation => { :room_id => room.to_param, :start_dt => Time.now, :end_dt => Time.now + 150.minutes }
    end
    assert assigns(:reservation).invalid?
    assert_equal assigns(:reservation).errors.full_messages.first, I18n.t('reservation.collaborative_requires_ccs')

    assert_no_difference('Reservation.count', 1) do
      post :create, :reservation => { :room_id => room.to_param, :start_dt => Time.now, :end_dt => Time.now + 150.minutes, :cc => "mr.invalid" }
    end
    assert assigns(:reservation).invalid?
    assert_equal assigns(:reservation).errors.full_messages.first, I18n.t('reservation.validate_cc')

    assert_no_difference('Reservation.count', 1) do
      post :create, :reservation => { :room_id => room.to_param, :start_dt => Time.now, :end_dt => Time.now + 150.minutes, :cc => user.email }
    end
    assert assigns(:reservation).invalid?
    assert_equal assigns(:reservation).errors.full_messages.first, I18n.t('reservation.current_user_is_only_email')
  end

  test "create new reservation grad" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in FactoryGirl.create(:user)
    assert_difference('Reservation.count', 1) do
      post :create, :reservation => { :room_id => FactoryGirl.create(:collaborative).to_param, :start_dt => '3020-03-01 11:30:00'.to_time + 2.days, :end_dt => '3020-03-01 11:30:00'.to_time + 2.days + 150.minutes, :cc => "dummy@silly.org" }
    end
    assert assigns(:user)
    assert assigns(:reservation)
    assert_response :success
    assert_template :index
    assert_difference('Reservation.count', -1) do
      Reservation.find(assigns(:reservation).to_param).destroy
    end
  end

  #test "create new reservation undergrad" do
  #  current_user = UserSession.create(users(:no_bookings_undergrad))
  #  VCR.use_cassette('reservations create new undergraduate') do
  #    assert_difference('Reservation.count', 1) do
  #      post :create, :reservation => { :id => 11, :room_id => FactoryGirl.create(:collaborative).id, :start_dt => Time.now + 2.days, :end_dt => Time.now + 2.days + 30.minutes, :cc => "dummy@silly.org" }
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
    @request.env["devise.mapping"] = Devise.mappings[:undergraduate]
    user = FactoryGirl.create(:undergraduate)
    sign_in user
    reservation = FactoryGirl.create(:reservation, user_id: user.id )
    put :delete, :reservation_id => reservation.id
    assert assigns(:user)
    assert assigns(:reservation)
    assert_equal flash[:success], I18n.t('reservations.delete.success')
  end

  test "can't delete existing reservation if not own" do

  end

  test "can't update existing reservation if not own" do

  end

  test "resend mail action" do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    admin = FactoryGirl.create(:admin)
    sign_in admin
    reservation = FactoryGirl.create(:reservation, user_id: admin.id)
    get :resend_email, :id => reservation.id
    assert assigns(:user)
    assert assigns(:reservation)
    assert_equal flash[:success], I18n.t('reservations.resend_email.success')
    assert_template :resend_email
  end

end
