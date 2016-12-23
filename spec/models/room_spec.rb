require 'rails_helper'

describe Room do
  let(:title) { "Title" }
  let(:opens_at) { " 7:00" }
  let(:closes_at) { " 7:00" }
  let(:room_group) { create(:room_group) }
  let(:room_group_id) { room_group.id }
  let(:room) { Room.new(title: title, opens_at: opens_at, closes_at: closes_at, room_group_id: room_group_id) }

  describe 'required fields' do
    subject { room }
    context 'when required fields all exist' do
      it { is_expected.to be_valid }
      it 'should be able to save' do
        expect { room.save! }.to change { Room.count }.by(1)
      end
    end
    context 'when title is blank' do
      let(:title) { nil }
      it { is_expected.to be_invalid }
      it 'should not be able to save' do
        expect { room.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end
    context 'when opens_at is blank' do
      let(:opens_at) { nil }
      it { is_expected.to be_invalid }
      it 'should not be able to save' do
        expect { room.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end
    context 'when closes_at is blank' do
      let(:closes_at) { nil }
      it { is_expected.to be_invalid }
      it 'should not be able to save' do
        expect { room.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end
    context 'when room_group_id is blank' do
      let(:room_group_id) { nil }
      it { is_expected.to be_invalid }
      it 'should not be able to save' do
        expect { room.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe '#current_reservations' do
    let!(:room) { create(:room) }
    let!(:reservation) { create(:reservation, room: room) }
    subject { room.current_reservations }
    it { is_expected.to_not be_empty }
  end
end
