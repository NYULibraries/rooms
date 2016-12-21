require 'rails_helper'

describe RoomsHelper do
  let(:room) { create(:room) }
  before { helper.instance_variable_set(:@room, room) }

  describe '#default_opens_at_hour' do
    subject { helper.default_opens_at_hour }
    it { is_expected.to eql 7 }
  end

  describe '#default_closes_at_hour' do
    subject { helper.default_closes_at_hour }
    it { is_expected.to eql 1 }
  end

  describe '#default_hour' do
    let(:hours) { nil }
    subject { helper.default_hour(hours) }
    context 'when hours is nil' do
      it { is_expected.to eql 1 }
    end
    context 'when hours is less than 12' do
      let(:hours) { '07:00' }
      it { is_expected.to eql 7 }
    end
    context 'when hours is more than 12' do
      let(:hours) { '14:00' }
      it { is_expected.to eql 2 }
    end
  end

  describe '#default_opens_at_minute' do
    subject { helper.default_opens_at_minute }
    it { is_expected.to eql 0 }
  end

  describe '#default_closes_at_minute' do
    subject { helper.default_closes_at_minute }
    it { is_expected.to eql 0 }
  end

  describe '#default_minute' do
    let(:hours) { nil }
    subject { helper.default_minute(hours) }
    context 'when hours are nil' do
      it { is_expected.to eql 0 }
    end
    context 'when hours are not nil' do
      let(:hours) { '14:30' }
      it { is_expected.to eql 30 }
    end
  end

  describe '#default_opens_at_ampm' do
    subject { helper.default_opens_at_ampm }
    it { is_expected.to eql 'am' }
  end

  describe '#default_closes_at_ampm' do
    subject { helper.default_closes_at_ampm }
    it { is_expected.to eql 'am' }
  end

  describe '#default_ampm' do
    let(:hours) { nil }
    subject { helper.default_ampm(hours) }
    context 'when hours is nil' do
      it { is_expected.to eql 'am' }
    end
    context 'when hours is less than 12' do
      let(:hours) { '07:00' }
      it { is_expected.to eql 'am' }
    end
    context 'when hours is more than 12' do
      let(:hours) { '14:00' }
      it { is_expected.to eql 'pm' }
    end
  end

  describe '#display_hours' do
    subject { helper.display_hours }
    context 'when the opens_at and closes_at are the same' do
      let(:room) { create(:room, closes_at: '07:00') }
      it { is_expected.to eql I18n.t('room.open_24_hours') }
    end
    context 'when the opens_at and closes_at are different' do
      it { is_expected.to eql " 7:00 am -  1:00 am" }
    end
  end

  describe '#opens_at' do
    subject { helper.opens_at }
    it { is_expected.to eql " 7:00 am" }
  end

  describe '#closes_at' do
    subject { helper.closes_at }
    it { is_expected.to eql " 1:00 am" }
  end

  describe '#room_group_selected?' do
    let(:room_group) { create(:room_group) }
    before { allow(helper).to receive(:params).and_return({ room: { room_group_id: room_group.id.to_s } }) }
    subject { helper.room_group_selected?(room_group) }
    it { is_expected.to be true }
  end
end
