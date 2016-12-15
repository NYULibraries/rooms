require 'rails_helper'

describe BlocksController do

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  let!(:block) { create(:block) }
  before { allow(controller).to receive(:current_user).and_return(admin) }

  describe 'GET /admin/blocks' do
    before { get :index }
    subject { response }

    context 'when user is an admin' do
      it 'should return blocks' do
        expect(assigns(:blocks)).to_not be_empty
        expect(assigns(:rooms)).to_not be_empty
        expect(subject).to render_template :index
      end
    end
    context 'when user is not an admin' do
      let(:admin) { create(:user) }
      it 'should return an access denied error' do
        expect(subject).to render_template 'user_sessions/unauthorized_action'
      end
    end
  end

  describe 'GET /admin/blocks/new' do
    before { get :new }
    subject { assigns(:block) }

    it { is_expected.to_not be_nil }
    its(:is_block) { is_expected.to be true }
  end

  describe 'POST /admin/blocks' do
    let!(:room) { create(:room) }
    let(:title) { 'custom title' }

    context 'when there are no existing reservations in the submitted block' do
      before { post :create, reservation: attributes_for(:block, room_id: room.id, title: title) }
      subject { response }
      it { is_expected.to redirect_to blocks_url }
      it 'should create a new user with the parameters passed in' do
        expect { post :create, reservation: attributes_for(:block, room_id: room.id) }.to change { Reservation.count }.by(1)
        expect(flash[:success]).to eql I18n.t('blocks.create.success')
      end
      context 'when a title is specified' do
        it 'should use that specified title to label this block' do
          expect(assigns(:block).title).to eql title
        end
      end
      context 'when no title is specified' do
        let(:title) { nil }
        it 'should use the default block title' do
          expect(assigns(:block).title).to eql I18n.t('blocks.default_title')
        end
      end
    end
    context 'when there are some existing reservations in the submitted block' do
      before(:all) do
        @existing_reservation = create(:reservation)
        @existing_block = create(:block)
        Room.import; Reservation.import
        sleep 3
      end
      context 'and those reservations are NOT blocks' do
        before { post :create, reservation: { room_id: @existing_reservation.room_id, start_dt: @existing_reservation.start_dt, end_dt: @existing_reservation.end_dt } }
        subject { response }
        it { is_expected.to render_template :new }
        it 'should assign an existing reservations instance variable' do
          expect(assigns(:block).existing_reservations).to_not be_empty
          expect(assigns(:block).existing_reservations.size).to eql 1
        end
      end
      context 'but those reservations ARE blocks' do
        before { post :create, reservation: { room_id: @existing_block.room_id, start_dt: @existing_block.start_dt, end_dt: @existing_block.end_dt } }
        subject { response }
        it { is_expected.to redirect_to blocks_url }
        it 'should assign an existing reservations instance variable' do
          expect(assigns(:block).existing_reservations).to be_empty
        end
      end
    end
  end

  describe 'POST /admin/blocks/destroy_existing_reservations' do
    before(:all) do
      @existing_reservation = create(:reservation)
      Room.import; Reservation.import
      sleep 3
    end
    let(:reservations_to_delete) { [@existing_reservation.id] }
    let(:cancellation_email) { "test body" }
    let(:reservation_params) do
      {
        room_id: @existing_reservation.room_id,
        start_dt: @existing_reservation.start_dt,
        end_dt: @existing_reservation.end_dt
      }
    end
    before { post :destroy_existing_reservations, reservation: reservation_params, cancel: cancel, reservations_to_delete: reservations_to_delete, cancellation_email: cancellation_email }
    context 'when deleting existing reservations about' do
      context 'and alerting those users about the cancellations' do
        let(:cancel) { 'delete_with_alert' }
        let!(:reservation) { create(:reservation) }
        let(:reservations_to_delete){ [reservation.id] }
        let(:cc_admin) { true }
        let(:cc_admin_email) { Faker::Internet.email }
        it 'should delete existing reservations' do
          expect(flash[:notice]).to eql I18n.t('blocks.destroy_existing_reservations.success')
        end
        it { is_expected.to redirect_to blocks_url }
        it 'should send emails to the cancelled reservation users' do
          expect {
            post :destroy_existing_reservations,
            reservation:
              {
                room_id: reservation.room_id,
                start_dt: reservation.start_dt,
                end_dt: reservation.end_dt
              },
              cancel: cancel,
              reservations_to_delete: reservations_to_delete,
              cancellation_email: cancellation_email,
              cc_admin: cc_admin,
              cc_admin_email: cc_admin_email
          }.to change { ActionMailer::Base.deliveries.count }.by(2)
        end
      end
      context 'but not alerting those users about the cancellations' do
        let(:cancel) { 'delete_no_alert' }
        it 'should mark existing reservation as deleted' do
          expect(Reservation.find(@existing_reservation.id).deleted).to be true
          expect(Reservation.find(@existing_reservation.id).deleted_by).to eql ({ by_block: true })
        end
      end
    end
  end

  describe 'GET /admin/blocks/index_existing_reservations' do
    let!(:existing_reservation) { create(:reservation) }
    before { get :index_existing_reservations, reservations_to_delete: [existing_reservation.id] }
    subject { response }
    it 'should contain the existing reservations in an instance variable' do
      expect(assigns(:existing_reservations)).to_not be_empty
      expect(assigns(:existing_reservations)).to include existing_reservation
    end
  end

  describe 'DELETE /admin/blocks/1' do
    let!(:block) { create(:block) }
    it 'should delete the block' do
      expect { delete :destroy, id: block.to_param }.to change { Reservation.count }.by(-1)
    end
  end
end
