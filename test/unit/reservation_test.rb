require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  
  setup :activate_authlogic
  
  def setup
    # This record exists in fixtures, use it to attempt to make overlapping reservations
    @overlap_attrs = {
      :room_id => rooms(:individual).to_param,
      :user_id => users(:real_user).to_param,
      :start_dt => '3020-10-01 13:30:00',
      :end_dt => '3020-10-01 15:00:00'
    }
  end
  
  test "required fields" do
    reservation_fields = { :user_id => users(:real_user).id , :room_id => rooms(:individual).id, :start_dt => 5.years.from_now, :end_dt => 5.years.from_now + 30.minutes }
    VCR.use_cassette('dont allow nil values') do
      assert Reservation.new(reservation_fields.merge({:user_id => nil})).invalid?
      assert Reservation.new(reservation_fields.merge({:room_id => nil})).invalid?
      assert Reservation.new(reservation_fields.merge({:start_dt => nil})).invalid?
      assert Reservation.new(reservation_fields.merge({:end_dt => nil})).invalid?
    end
  end
  
  test "belongs to user" do
    VCR.use_cassette('check belongs to user') do
      assert_nothing_raised() { reservations(:one).user }
      assert_equal reservations(:one).user, users(:real_user)
    end
  end
  
  test "belongs to room" do
    VCR.use_cassette('check belongs to room') do
      assert_nothing_raised() { reservations(:one).room }
      assert_equal reservations(:one).room, rooms(:individual)
    end
  end
  
  test "hours is serialized" do
    VCR.use_cassette('check hours are serialized') do
      @reservation = reservations(:deleted)
      assert_kind_of Hash, @reservation.deleted_by
    end
  end
  
  test "check for at least one cc on collaborative" do
    VCR.use_cassette('at least one cc collaborative') do
      reservation_fields = { :user_id => users(:real_user).id , :room_id => rooms(:collaborative).id, :start_dt => 3.years.from_now, :end_dt => 3.years.from_now + 30.minutes }
      @reservation = Reservation.new(reservation_fields)
      # CC is required for Collab rooms
      assert @reservation.invalid?
      assert_equal @reservation.errors.first.last, "For collaborative rooms, please add at least one other valid e-mail from your group." 
      # Not your own email address as CC tho...
      @reservation = Reservation.new(reservation_fields.merge({:cc => "real_user@university.edu"}))
      assert @reservation.invalid?
      assert_equal @reservation.errors.first.last, "For collaborative rooms, please add at least one other e-mail besides your own."
      # That's right, that's better
      @reservation = Reservation.new(reservation_fields.merge({:cc => "another_real_user@university.edu"}))
      assert @reservation.valid?
      assert_empty @reservation.errors
    end
  end
  
  test "for valid CC emails" do
    VCR.use_cassette('for valid cc emails') do
      reservation_fields = { :user_id => users(:real_user).id , :room_id => rooms(:collaborative).id, :start_dt => 3.years.from_now, :end_dt => 3.years.from_now + 30.minutes }
      @reservation = Reservation.new(reservation_fields)
      @reservation.cc = "valid@email.com, invalidemail"
      assert @reservation.invalid?
      assert_equal @reservation.errors.first.last, "One or more of the e-mails you entered is invalid."
      @reservation.cc = "invalidemail, valid@email.com"
      assert @reservation.invalid?
      assert_equal @reservation.errors.first.last, "One or more of the e-mails you entered is invalid."
      @reservation.cc = "valid2@test.edu, valid@email.com"
      assert @reservation.valid?
      assert_empty @reservation.errors
    end
  end
    
  test "doesnt allow overlap when: reservation falls inside existing reservation" do
    VCR.use_cassette('no overlap when inside') do
      @reservation = Reservation.new(@overlap_attrs.merge({:start_dt => reservations(:overlap).start_dt + 30.minutes, :end_dt => reservations(:overlap).end_dt - 30.minutes }))
      assert @reservation.invalid?
      assert !@reservation.save
      assert_equal @reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
    end
  end
  
  test "doesnt allow overlap when: reservation starts before and ends after existing reservation" do
    VCR.use_cassette('no overlap when spans') do
      @reservation = Reservation.new(@overlap_attrs.merge({:start_dt => reservations(:overlap).start_dt - 30.minutes, :end_dt => reservations(:overlap).end_dt + 30.minutes }))
      assert @reservation.invalid?
      assert !@reservation.save
      assert_equal @reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
    end
  end
  
  test "doesnt allow overlap when: reservation starts before and ends inside existing reservation" do
    VCR.use_cassette('no overlap when starts before') do
      @reservation = Reservation.new(@overlap_attrs.merge({:start_dt => reservations(:overlap).start_dt - 30.minutes, :end_dt => reservations(:overlap).end_dt - 30.minutes }))
      assert @reservation.invalid?
      assert !@reservation.save
      assert_equal @reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
    end
  end
  
  test "doesnt allow overlap when: reservation starts inside and ends after existing reservation" do
    VCR.use_cassette('no overlap when starts inside') do
      @reservation = Reservation.new(@overlap_attrs.merge({:start_dt => reservations(:overlap).start_dt + 30.minutes, :end_dt => reservations(:overlap).end_dt + 1.hour }))
      assert @reservation.invalid?
      assert !@reservation.save
      assert_equal @reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
    end
  end
  
  test "doesnt allow overlap when: reservation is exactly the same as existing reservation" do
    VCR.use_cassette('no overlap when same') do
      @reservation = Reservation.new(@overlap_attrs)
      assert @reservation.invalid?
      assert !@reservation.save
      assert_equal @reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
    end
  end
  
  test "does allow overlap when adjacent after" do
    VCR.use_cassette('overlap when adjacent after') do
      @reservation = Reservation.new(@overlap_attrs.merge({:start_dt => reservations(:overlap).end_dt, :end_dt => reservations(:overlap).end_dt + 1.hour }))
      assert @reservation.valid?
      assert_empty @reservation.errors
    end
  end
  
  test "does allow overlap when adjacent before" do
    VCR.use_cassette('overlap when adjacent before') do
      @reservation = Reservation.new(@overlap_attrs.merge({:start_dt => reservations(:overlap).start_dt - 30.minutes, :end_dt => reservations(:overlap).start_dt }))
      assert @reservation.valid?
      assert_empty @reservation.errors
    end
  end
  
end
