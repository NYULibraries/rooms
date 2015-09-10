require 'spec_helper'

describe ReservationsController do

  let(:user) { create(:user) }
  let(:start_dt) { Time.now }
  let(:end_dt) { start_dt + 30.minutes }
  let(:which_date) { start_dt.strftime("%Y/%m/%d") }
  let(:hour) { "1" }
  let(:minute) { "00" }
  let(:ampm) { "pm" }
  let(:how_long) { "30" }
  let(:reservation_params) do
    {
      which_date: which_date,
      hour: hour,
      minute: minute,
      ampm: ampm,
      how_long: how_long
    }
  end
  before(:each) { controller.stub(:current_user).and_return(user) }

  describe "GET /new" do
    before { get :new, reservation: reservation_params }
    subject { assigns(:rooms) }
    context "when user is an undergraduate" do
      let(:user) { create(:undergraduate) }
      context "and time request is greater than 90 minutes" do
        let(:how_long) { "150" }
        it { should be_nil }
      end
      context "and time request is less than 90 minutes" do
        let(:how_long) { "89" }
        it { should_not be_nil }
      end
      context "and time request is equal to 90 minutes" do
        let(:how_long) { "90" }
        it { should_not be_nil }
      end
    end

  end

end
