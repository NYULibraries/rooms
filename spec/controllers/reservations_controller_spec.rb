require 'spec_helper'

describe ReservationsController, elasticsearch: true do
  let(:user) { create(:undergraduate) }
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
  before { Room.import; Reservation.import }

  describe 'GET /reservations' do
    before { allow(controller).to receive(:current_user).and_return(user) }
    before { get :index }
    subject { response }
    it 'should assign a user instance' do
      expect(assigns(:user)).to eql user
    end
    it 'should assign a new reservation instance' do
      expect(assigns(:reservation)).to_not be_nil
    end
    it 'should assign an existing reservations instance' do
      expect(assigns(:reservations)).to_not be_nil
    end
  end

  describe 'GET /reservations/1' do
    before { allow(controller).to receive(:current_user).and_return(user) }
    let(:room) { create(:collaborative) }
    let(:reservation) { create(:reservation, user: user, room: room, cc: Faker::Internet.email) }
    before { get :edit, id: reservation.to_param }
    subject { response }
    it 'should assign a user instance' do
      expect(assigns(:user)).to eql user
    end
    it 'should assign the found reservation instance' do
      expect(assigns(:reservation)).to_not be_nil
      expect(assigns(:reservation).id).to eql reservation.id
    end
    it { is_expected.to render_template(:edit) }
  end

  describe 'PATCH /reservations/1' do
    before { allow(controller).to receive(:current_user).and_return(user) }
    let(:room) { create(:collaborative) }
    let(:title) { "Arthurian Romances study session" }
    let(:reservation) { create(:reservation, user: user, room: room, cc: Faker::Internet.email) }
    before { patch :update, id: reservation, reservation: { title: title } }
    subject { response }
    it 'should assign a user instance' do
      expect(assigns(:user)).to eql user
    end
    it 'should assign the found reservation instance' do
      expect(assigns(:reservation)).to_not be_nil
      expect(assigns(:reservation).title).to eql title
    end
    it { is_expected.to redirect_to root_url }
  end

  describe "GET /new" do
    before { allow(controller).to receive(:current_user).and_return(user) }
    let(:room) { create(:collaborative) }
    before { Room.import }
    before { get :new, reservation: reservation_params }
    subject { assigns(:rooms) }
    context "when user is an undergraduate" do
      context 'and date is incorrectly formatted' do
        let(:which_date) { "i'm not a date, i'm a string" }
        it 'should return a flash error' do
          expect(flash[:error]).to eql I18n.t('reservation.date_formatted_correctly')
        end
      end
      context 'and date is correctly formatted' do
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
      it { is_expected.to render_template(:new) }
    end

  end

  describe 'restrictions' do
    context 'when a user already created a reservation today' do
      before(:all) do
        room = create(:room)
        @existing_user = create(:user)
        @existing_reservation = create(:reservation, room: room, user: @existing_user)
        Room.import; Reservation.import
        sleep 3
      end
      before { allow(controller).to receive(:current_user).and_return(@existing_user) }
      before { get :new, reservation: reservation_params }
      subject { response }
      it { is_expected.to render_template "user_sessions/unauthorized_action" }
      it 'should return a flash error' do
        expect(flash[:error]).to eql I18n.t('unauthorized.create_today.reservation')
      end
    end
    context 'when a user alraedy created a reservation for the same day' do
      before(:all) do
        room = create(:room)
        @existing_user = create(:user)
        Timecop.freeze(Date.today - 1.day) do
          @existing_reservation = create(:reservation, room: room, user: @existing_user)
        end
        Room.import; Reservation.import
        sleep 3
      end
      let(:reservation_params) do
        {
          start_dt: @existing_reservation.start_dt,
          end_dt: @existing_reservation.end_dt
        }
      end
      before { allow(controller).to receive(:current_user).and_return(@existing_user) }
      before { get :new, reservation: reservation_params }
      subject { response }
      it { is_expected.to render_template "user_sessions/unauthorized_action" }
      it 'should return a flash error' do
        expect(flash[:error]).to eql I18n.t('unauthorized.create_for_same_day.reservation')
      end
    end
  end


end
