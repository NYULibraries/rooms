require 'rails_helper'

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
    let(:format) { :html }
    before { allow(controller).to receive(:current_user).and_return(user) }
    before { get :index, format: format }
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
    context 'when a csv download is requested' do
      let(:format) { :csv }
      its(:content_type) { is_expected.to eql 'text/csv' }
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
        context 'and user is a undergraduate' do
          context "and time request is greater than 90 minutes" do
            let(:how_long) { "150" }
            it { is_expected.to be_nil }
            it { is_expected.to render_template('user_sessions/unauthorized_action') }
          end
          context "and time request is less than 90 minutes" do
            let(:how_long) { "89" }
            it { is_expected.to_not be_nil }
            it { is_expected.to render_template(:new) }
          end
          context "and time request is equal to 90 minutes" do
            let(:how_long) { "90" }
            it { is_expected.to_not be_nil }
            it { is_expected.to render_template(:new) }
          end
        end
        context 'and user is a graduate' do
          let(:user) { create(:user) }
          context "and time request is greater than 3 hours" do
            let(:how_long) { "181" }
            it { is_expected.to be_nil }
            it { is_expected.to render_template('user_sessions/unauthorized_action') }
          end
          context "and time request is greater than 90 minutes" do
            let(:how_long) { "150" }
            it { is_expected.to_not be_nil }
            it { is_expected.to render_template(:new) }
          end
          context "and time request is less than 90 minutes" do
            let(:how_long) { "89" }
            it { is_expected.to_not be_nil }
            it { is_expected.to render_template(:new) }
          end
          context "and time request is equal to 90 minutes" do
            let(:how_long) { "90" }
            it { is_expected.to_not be_nil }
            it { is_expected.to render_template(:new) }
          end
        end
      end
      it { is_expected.to render_template(:new) }
    end

  end

  # This is not technically a DELETE because it just sets `deleted: true` on the record
  describe 'PATCH /reservations/1/delete' do
    let(:room) { create(:room) }
    let(:user) { create(:user) }
    let(:reservation) { create(:reservation, room: room, user: user) }
    let(:return_to) { nil }
    before { allow(controller).to receive(:current_user).and_return(user) }

    context 'when user is trying to delete their own reservation' do
      before { patch :delete, reservation_id: reservation.to_param, return_to: return_to }
      subject { response }

      context 'and a return url param WAS NOT passed in' do
        it 'should delete the reservation successfully and redirect' do
          expect(flash[:success]).to eql I18n.t('reservations.delete.success')
          expect(subject).to redirect_to "http://test.host/"
        end
      end
      context 'and a return url param WAS passed in' do
        let(:return_to) { 'user' }
        it 'should delete the reservation successfully and redirect' do
          expect(flash[:success]).to eql I18n.t('reservations.delete.success')
          expect(subject).to redirect_to "http://test.host/admin/users/#{user.id}"
        end
      end
    end
    context 'when user is trying to delete someone else\'s reservation' do
      before { patch :delete, reservation_id: create(:reservation).to_param }
      subject { response }

      it 'should return access denied' do
        expect(flash[:error]).to eql 'Access denied!'
      end
    end
  end

  describe '#resend_email' do
    let(:room) { create(:room) }
    let(:user) { create(:user) }
    let(:reservation) { create(:reservation, room: room, user: user) }
    before { allow(controller).to receive(:current_user).and_return(user) }

    describe 'GET /reservations/1/resend_email' do
      before { get :resend_email, id: reservation.to_param }
      subject { response }
      context 'when user is trying to resend email for their own reservation' do
        it 'should deliver an email' do
          expect { get :resend_email, id: reservation.to_param }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
        it 'should return a success message' do
          expect(flash[:success]).to eql I18n.t('reservations.resend_email.success')
        end
      end
      context 'when user is trying to resend email for someone else\'s reservation' do
        let(:reservation) { create(:reservation) }
        it 'should return an access denied message' do
          expect(flash[:error]).to eql "Access denied!"
        end
      end
    end

    describe 'POST /reservations/1/resend_email' do
      before { post :resend_email, id: reservation.to_param }
      subject { response }
      context 'when user is trying to resend email for their own reservation' do
        it 'should deliver an email' do
          expect { get :resend_email, id: reservation.to_param }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
        it 'should return a success message' do
          expect(flash[:success]).to eql I18n.t('reservations.resend_email.success')
        end
      end
      context 'when user is trying to resend email for someone else\'s reservation' do
        let(:reservation) { create(:reservation) }
        it 'should return an access denied message' do
          expect(flash[:error]).to eql "Access denied!"
        end
      end
    end
  end


  describe '#new and #create policies' do
    context 'when a user is trying to create a reservation for the first time today and for a certain day' do
      let(:room) { create(:room) }
      let(:user) { create(:user) }
      before { allow(controller).to receive(:current_user).and_return(user) }
      it 'should create a new reservation' do
        expect { post :create, reservation: { start_dt: start_dt, end_dt: end_dt, room_id: room.to_param } }.to change { Reservation.count }.by(1)
        expect(response).to render_template(:index)
        expect(flash[:success]).to eql I18n.t('reservations.create.success')
      end
    end
    context 'when a user already created a reservation today' do
      before(:all) do
        room = create(:room)
        @existing_user = create(:user)
        @existing_reservation = create(:reservation, room: room, user: @existing_user)
        Room.import; Reservation.import
        sleep 3
      end
      before { allow(controller).to receive(:current_user).and_return(@existing_user) }
      context 'and user is trying to select a date to load up the grid view' do
        before { get :new, reservation: reservation_params }
        subject { response }

        it { is_expected.to render_template "user_sessions/unauthorized_action" }
        it 'should return a flash error' do
          expect(flash[:error]).to eql I18n.t('unauthorized.create_today.reservation')
        end
      end
      context 'and user has already selected a timeslot and is trying to post to create action' do
        before { post :create, reservation: reservation_params }
        subject { response }
        let(:reservation_params) do
          {
            start_dt: start_dt,
            end_dt: end_dt
          }
        end

        it { is_expected.to render_template "user_sessions/unauthorized_action" }
        it 'should return a flash error' do
          expect(flash[:error]).to eql I18n.t('unauthorized.create_today.reservation')
        end
      end
    end
    context 'when a user already created a reservation for the same day' do
      before(:all) do
        room = create(:room)
        @existing_user = create(:user)
        Timecop.freeze(Date.today - 1.day) do
          @existing_reservation = create(:reservation, room: room, user: @existing_user)
        end
        Room.import; Reservation.import
        sleep 3
      end
      before { allow(controller).to receive(:current_user).and_return(@existing_user) }
      let(:reservation_params) do
        {
          start_dt: @existing_reservation.start_dt,
          end_dt: @existing_reservation.end_dt
        }
      end
      context 'and user is trying to select a date on the grid view' do
        before { get :new, reservation: reservation_params }
        subject { response }

        it { is_expected.to render_template "user_sessions/unauthorized_action" }
        it 'should return a flash error' do
          expect(flash[:error]).to eql I18n.t('unauthorized.create_for_same_day.reservation')
        end
      end
      context 'and user has already selected a timeslot and is trying to post to create action' do
        before { get :new, reservation: reservation_params }
        subject { response }

        it { is_expected.to render_template "user_sessions/unauthorized_action" }
        it 'should return a flash error' do
          expect(flash[:error]).to eql I18n.t('unauthorized.create_for_same_day.reservation')
        end
      end
    end
  end



end
