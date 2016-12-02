require 'spec_helper'

describe RoomsDecorator do

  let(:rooms) { RoomsDecorator.new(create(:collaborative)) }
  let(:start_dt) { Time.now.strftime("%Y-%m-%d %H:%M:%S").to_datetime }
  let(:end_dt) { 3.hours.from_now.strftime("%Y-%m-%d %H:%M:%S").to_datetime }

  xdescribe '#find_reservations_by_range' do
    subject { rooms.find_reservations_by_range(start_dt, end_dt) }
    it { should eql '' }
  end

end
