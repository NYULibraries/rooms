require 'test_helper'

class RoomTest < ActiveSupport::TestCase

  #

  test "title is not empty" do
   @room = FactoryGirl.create(:room)
   @room.title = nil
   assert_raises(ActiveRecord::RecordInvalid) { @room.save! }
   assert_not_empty(@room.errors)
  end

  test "reservations belong to room" do
    room = FactoryGirl.create(:room, reservations: [FactoryGirl.create(:reservation)])
    assert_nothing_raised() { room.reservations }
    assert_equal 1, room.reservations.count
  end

end
