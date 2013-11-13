require 'test_helper'

class RoomTest < ActiveSupport::TestCase

  setup :activate_authlogic
  
  test "title is not empty" do
   @room = rooms(:individual)
   @room.title = nil
   assert_raises(ActiveRecord::RecordInvalid) { @room.save! }
   assert_not_empty(@room.errors)
  end
  
  test "reservations belong to room" do
    assert_nothing_raised() { rooms(:individual).reservations }
    assert_equal rooms(:individual).reservations.count, 8
  end
  
end
