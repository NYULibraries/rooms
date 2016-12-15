require 'rails_helper'

describe Reservation, elasticsearch: true do
  before(:all) do
    room = create(:room)
    @overlapping_reservation = create(:reservation, room: room)
    Room.import; Reservation.import
    sleep 3
  end

  let(:room) { create(:room) }
  let(:user) { create(:user) }
  let(:room_id) { room.id }
  let(:user_id) { user.id }
  let(:start_dt) { Faker::Time.forward(50, :afternoon) }
  let(:end_dt) { start_dt + 90.minutes }
  let(:cc) { nil }
  let(:params) do
    {
      user_id: user_id,
      room_id: room_id,
      start_dt: start_dt,
      end_dt: end_dt,
      cc: cc
    }
  end
  before { Room.import; Reservation.import }

  describe '.new' do
    subject { Reservation.new(params) }
    describe 'required fields' do
      it { is_expected.to be_valid }
      context 'when user is nil' do
        let(:user_id) { nil }
        it { is_expected.to be_invalid }
      end
      context 'when room is nil' do
        let(:room_id) { nil }
        it { is_expected.to be_invalid }
      end
      context 'when start date is nil' do
        let(:start_dt) { nil }
        let(:end_dt) { Faker::Time.forward(50, :afternoon) }
        it { is_expected.to be_invalid }
      end
      context 'when end date is nil' do
        let(:end_dt) { nil }
        it { is_expected.to be_invalid }
      end
    end

    it 'should belong to the user who created it' do
      expect(subject.user).to eql user
    end

    it 'should belong to a room' do
      expect(subject.room).to eql room
    end

    it 'should have a serialized deleted_by hash' do
      expect(subject.deleted_by).to be_instance_of Hash
    end

    describe '#cc' do
      context 'when the room is collaborative' do
        let(:room) { create(:collaborative) }
        context 'and no CC is provided' do
          it 'should require at least one CC' do
            expect(subject).to be_invalid
            expect(subject.errors.messages[:base]).to include I18n.t('reservation.collaborative_requires_ccs')
          end
        end
        context 'and the only CC provided is the user\'s' do
          let(:cc) { user.email }
          it 'should require at least one CC other than the user\'s' do
            expect(subject).to be_invalid
            expect(subject.errors.messages[:base]).to include I18n.t('reservation.current_user_is_only_email')
          end
        end
        context 'and one or more of the CCs provided is an invalid email' do
          let(:cc) { "#{Faker::Internet.email},wrong..."}
          it 'should require valid emails' do
            expect(subject).to be_invalid
            expect(subject.errors.messages[:base]).to include I18n.t('reservation.validate_cc')
          end
        end
        context 'and one or more of the CCs provided is valid' do
          let(:cc) { "#{Faker::Internet.email},#{Faker::Internet.email},#{user.email}" }
          it 'should require valid emails' do
            expect(subject).to be_valid
            expect(subject.errors).to be_empty
          end
        end
      end
    end

    describe 'overlapping restrictions' do
      let(:overlapping_user_id) { @overlapping_reservation.user_id }
      let(:overlapping_room_id) { @overlapping_reservation.room_id }
      let(:overlapping_start_dt) { @overlapping_reservation.start_dt }
      let(:overlapping_end_dt) { @overlapping_reservation.end_dt }
      let(:overlapping_attrs) do
        {
          user_id: overlapping_user_id,
          room_id: overlapping_room_id,
          start_dt: overlapping_start_dt,
          end_dt: overlapping_end_dt
        }
      end
      subject { Reservation.new(overlapping_attrs) }
      context 'when reservation falls inside another an existing reservation' do
        let(:overlapping_start_dt) { @overlapping_reservation.start_dt + 30.minutes }
        let(:overlapping_end_dt) { @overlapping_reservation.end_dt - 30.minutes }
        it 'should be invalid and return errors' do
          expect(subject).to be_invalid
          expect(subject.errors.messages[:base]).to include I18n.t('reservation.reservation_available')
        end
      end
      context 'when reservation starts before and ends after an existing reservation' do
        let(:overlapping_start_dt) { @overlapping_reservation.start_dt - 30.minutes }
        let(:overlapping_end_dt) { @overlapping_reservation.end_dt + 30.minutes }
        it 'should be invalid and return errors' do
          expect(subject).to be_invalid
          expect(subject.errors.messages[:base]).to include I18n.t('reservation.reservation_available')
        end
      end
      context 'when reservation starts before and ends during an existing reservation' do
        let(:overlapping_start_dt) { @overlapping_reservation.start_dt - 30.minutes }
        let(:overlapping_end_dt) { @overlapping_reservation.end_dt - 30.minutes }
        it 'should be invalid and return errors' do
          expect(subject).to be_invalid
          expect(subject.errors.messages[:base]).to include I18n.t('reservation.reservation_available')
        end
      end
      context 'when reservation starts during and ends after an existing reservation' do
        let(:overlapping_start_dt) { @overlapping_reservation.start_dt + 30.minutes }
        let(:overlapping_end_dt) { @overlapping_reservation.end_dt + 30.minutes }
        it 'should be invalid and return errors' do
          expect(subject).to be_invalid
          expect(subject.errors.messages[:base]).to include I18n.t('reservation.reservation_available')
        end
      end
      context 'when reservation is exactly the same timeslot as an existing reservation' do
        let(:overlapping_start_dt) { @overlapping_reservation.start_dt }
        let(:overlapping_end_dt) { @overlapping_reservation.end_dt }
        it 'should be invalid and return errors' do
          expect(subject).to be_invalid
          expect(subject.errors.messages[:base]).to include I18n.t('reservation.reservation_available')
        end
      end
      context 'when reservation is directly AFTER an existing reservation' do
        let(:overlapping_start_dt) { @overlapping_reservation.end_dt }
        let(:overlapping_end_dt) { @overlapping_reservation.end_dt + 1.hour }
        it { is_expected.to be_valid }
      end
      context 'when reservation is directly BEFORE an existing reservation' do
        let(:overlapping_start_dt) { @overlapping_reservation.start_dt - 1 .hour }
        let(:overlapping_end_dt) { @overlapping_reservation.start_dt }
        it { is_expected.to be_valid }
      end
    end

  end



end
