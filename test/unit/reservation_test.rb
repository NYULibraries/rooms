require 'test_helper'

class ReservationTest < ActiveSupport::TestCase

  def overlap_reservation
    @overlap_reservation
  end

  def setup
    @overlap_reservation ||= FactoryGirl.create(:reservation, start_dt: (time = Faker::Time.forward(50, :afternoon)), end_dt: (time + 2.hours))
    wait_for_tire_index
  end

  test "required fields" do
    reservation_fields = {
      user_id: FactoryGirl.create(:user).id,
      room_id: FactoryGirl.create(:room).id,
      start_dt: (time = Faker::Time.forward(50, :afternoon)),
      end_dt: time + 30.minutes
    }
    wait_for_tire_index
    assert Reservation.new(reservation_fields.merge({:user_id => nil})).invalid?
    assert Reservation.new(reservation_fields.merge({:room_id => nil})).invalid?
    assert Reservation.new(reservation_fields.merge({:start_dt => nil})).invalid?
    assert Reservation.new(reservation_fields.merge({:end_dt => nil})).invalid?
  end

  test "belongs to user" do
    user = FactoryGirl.create(:user)
    reservation = FactoryGirl.create(:reservation, user_id: user.id)
    assert_nothing_raised() { reservation.user }
    assert_equal user, reservation.user
  end

  test "belongs to room" do
    user = FactoryGirl.create(:user)
    reservation = FactoryGirl.create(:reservation, user_id: user.id)
    assert_nothing_raised() { reservation.room }
    assert_equal user, reservation.user
  end

  test "hours is serialized" do
    assert_kind_of Hash, FactoryGirl.create(:reservation, deleted: true, deleted_by: {by_user: 1}).deleted_by
  end

  test "check for at least one cc on collaborative" do
    user = FactoryGirl.create(:user)
    room = FactoryGirl.create(:room, collaborative: true)
    reservation_fields = {
      user_id: user.id,
      room_id: room.id,
      start_dt: (time = Faker::Time.forward(50, :afternoon)),
      end_dt: (time + 30.minutes)
    }
    reservation = Reservation.new(reservation_fields)
    wait_for_tire_index
    # CC is required for Collab rooms
    assert reservation.invalid?
    assert_equal reservation.errors.first.last, "For collaborative rooms, please add at least one other valid e-mail from your group."
    # Not your own email address as CC tho...
    reservation = Reservation.new(reservation_fields.merge({:cc => user.email}))
    assert reservation.invalid?
    assert_equal reservation.errors.first.last, "For collaborative rooms, please add at least one other e-mail besides your own."
    # That's right, that's better
    reservation = Reservation.new(reservation_fields.merge({:cc => "another_real_user@university.edu"}))
    assert reservation.valid?
    assert_empty reservation.errors
  end

  test "for valid CC emails" do
    user = FactoryGirl.create(:user)
    room = FactoryGirl.create(:room, collaborative: true)
    reservation_fields = {
      user_id: user.id,
      room_id: room.id,
      start_dt: (time = Faker::Time.forward(50, :afternoon)),
      end_dt: (time + 30.minutes)
    }
    reservation = Reservation.new(reservation_fields)
    wait_for_tire_index
    reservation.cc = "valid@email.com, invalidemail"
    assert reservation.invalid?
    assert_equal reservation.errors.first.last, "One or more of the e-mails you entered is invalid."
    reservation.cc = "invalidemail, valid@email.com"
    assert reservation.invalid?
    assert_equal reservation.errors.first.last, "One or more of the e-mails you entered is invalid."
    reservation.cc = "valid2@test.edu, valid@email.com"
    assert reservation.valid?
    assert_empty reservation.errors
  end

  test "doesnt allow overlap when: reservation falls inside existing reservation" do
    overlap_attrs = {
      user_id: overlap_reservation.user.id,
      room_id: overlap_reservation.room.id,
      start_dt: overlap_reservation.start_dt + 30.minutes,
      end_dt: overlap_reservation.end_dt - 30.minutes
    }
    reservation = Reservation.new(overlap_attrs)
    wait_for_tire_index
    assert reservation.invalid?
    assert !reservation.save
    assert_equal reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
  end

  test "doesnt allow overlap when: reservation starts before and ends after existing reservation" do
    overlap_attrs = {
      user_id: overlap_reservation.user.id,
      room_id: overlap_reservation.room.id,
      start_dt: overlap_reservation.start_dt - 30.minutes,
      end_dt: overlap_reservation.end_dt + 30.minutes
    }
    reservation = Reservation.new(overlap_attrs)
    wait_for_tire_index
    assert reservation.invalid?
    assert !reservation.save
    assert_equal reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
  end

  test "doesnt allow overlap when: reservation starts before and ends inside existing reservation" do
    overlap_attrs = {
      user_id: overlap_reservation.user.id,
      room_id: overlap_reservation.room.id,
      start_dt: overlap_reservation.start_dt - 30.minutes,
      end_dt: overlap_reservation.end_dt - 30.minutes
    }
    reservation = Reservation.new(overlap_attrs)
    wait_for_tire_index
    assert reservation.invalid?
    assert !reservation.save
    assert_equal reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
  end

  test "doesnt allow overlap when: reservation starts inside and ends after existing reservation" do
    overlap_attrs = {
      user_id: overlap_reservation.user.id,
      room_id: overlap_reservation.room.id,
      start_dt: overlap_reservation.start_dt + 30.minutes,
      end_dt: overlap_reservation.end_dt + 30.minutes
    }
    reservation = Reservation.new(overlap_attrs)
    wait_for_tire_index
    assert reservation.invalid?
    assert !reservation.save
    assert_equal reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
  end

  test "doesnt allow overlap when: reservation is exactly the same as existing reservation" do
    overlap_attrs = {
      user_id: overlap_reservation.user.id,
      room_id: overlap_reservation.room.id,
      start_dt: overlap_reservation.start_dt,
      end_dt: overlap_reservation.end_dt
    }
    reservation = Reservation.new(overlap_attrs)
    wait_for_tire_index
    assert reservation.invalid?
    assert !reservation.save
    assert_equal reservation.errors.first.last, "Sorry, your selected reservation slot was just taken. Please check the availability again."
  end

  test "does allow overlap when adjacent after" do
    overlap_attrs = {
      user_id: overlap_reservation.user.id,
      room_id: overlap_reservation.room.id,
      start_dt: overlap_reservation.end_dt,
      end_dt: overlap_reservation.end_dt + 1.hour
    }
    reservation = Reservation.new(overlap_attrs)
    wait_for_tire_index
    assert reservation.valid?
    assert_empty reservation.errors
  end

  test "does allow overlap when adjacent before" do
    overlap_attrs = {
      user_id: overlap_reservation.user.id,
      room_id: overlap_reservation.room.id,
      start_dt: overlap_reservation.start_dt - 1.hour,
      end_dt: overlap_reservation.start_dt
    }
    reservation = Reservation.new(overlap_attrs)
    wait_for_tire_index
    assert reservation.valid?
    assert_empty reservation.errors
  end

end
