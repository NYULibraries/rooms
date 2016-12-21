require 'rails_helper'

describe ApplicationHelper do
  describe '#prettify_time' do
    let(:hour) { 13 }
    let(:t) { Time.new(2016, 1, 5, hour, 0, 0) }
    subject { helper.prettify_time(t) }
    context 'when hour is greater than 12' do
      it { is_expected.to eql "<span class=\"hidden-xs\">01:00 pm</span><span class=\"visible-xs\">01:00</span>" }
    end
    context 'when hour is less than 12' do
      let(:hour) { 5 }
      it { is_expected.to eql "<span class=\"hidden-xs\">05:00 am</span><span class=\"visible-xs\">05:00</span>" }
    end
    context 'when hour is 0' do
      let(:hour) { 0 }
      it { is_expected.to eql "<span class=\"hidden-xs\">12:00 am</span><span class=\"visible-xs\">12:00</span>" }
    end
  end

  describe '#prettify_date' do
    let(:d) { DateTime.new(2016, 1, 5, 1, 0) }
    subject { helper.prettify_date(d) }
    context 'when date parameter is blank' do
      let(:d) { '' }
      it { is_expected.to be_nil }
    end
    context 'when date parameter is not blank' do
      it { is_expected.to eql 'Tue. Jan 05, 2016 01:00 AM' }
    end
  end

  describe '#prettify_simple_date' do
    let(:d) { DateTime.new(2016, 1, 5, 1, 0) }
    subject { helper.prettify_simple_date(d) }
    it { is_expected.to eql '01/05/2016' }
  end

  describe '#prettify_dayofweek' do
    let(:d) { DateTime.new(2016, 1, 5, 1, 0) }
    subject { helper.prettify_dayofweek(d) }
    it { is_expected.to eql 'Tue' }
  end

  describe '#simple_date_header' do
    let(:d) { DateTime.new(2016, 1, 5, 1, 0) }
    subject { helper.simple_date_header(d) }
    it { is_expected.to eql 'Tuesday, January  5, 2016' }
  end

  describe '#set_default_hour' do
    subject { helper.set_default_hour }
    after { Timecop.return }
    context 'when hour is not midnight or noon' do
     context 'and minutes are greater than half past the hour' do
        before { Timecop.freeze(Time.local(2008, 9, 1, 1, 30, 0)) }
        it { is_expected.to eql 2 }
      end
    end
    context 'when hour is midnight or noon' do
      context 'and minutes are greater than half past the hour' do
        before { Timecop.freeze(Time.local(2008, 9, 1, 12, 30, 0)) }
        it { is_expected.to eql 1 }
      end
    end
    context 'and minutes are less than half past the hour' do
      before { Timecop.freeze(Time.local(2008, 9, 1, 1, 29, 0)) }
      it { is_expected.to eql 1 }
    end
  end

  describe '#set_default_minute' do
    subject { helper.set_default_minute }
    after { Timecop.return }
    context 'when minutes are less than half past the hour' do
      before { Timecop.freeze(Time.local(2008, 9, 1, 1, 29, 0)) }
      it { is_expected.to eql 30 }
    end
    context 'when minutes are greater than half past the hour' do
      before { Timecop.freeze(Time.local(2008, 9, 1, 1, 35, 0)) }
      it { is_expected.to eql 0 }
    end
  end

  describe '#set_default_ampm' do
    subject { helper.set_default_ampm }
    after { Timecop.return }
    context 'when hour is 11 and minutes are more than half past the hour' do
      before { Timecop.freeze(Time.local(2008, 9, 1, 11, 31, 0)) }
      it { is_expected.to eql 'pm' }
    end
    context 'when hour is not 11' do
      before { Timecop.freeze(Time.local(2008, 9, 1, 1, 35, 0)) }
      it { is_expected.to eql 'am' }
    end
  end

  describe '#get_formatted_text' do
    let(:t) { '<badtag><a badattr="bad" href="#">Text</a></badtag>' }
    let(:css) { nil }
    subject { helper.get_formatted_text(t, css) }
    context 'when there is no css class' do
      it { is_expected.to eql '<p><a href="#">Text</a></p>' }
    end
    context 'when there is a css class' do
      let(:css) { 'testclass' }
      it { is_expected.to eql '<p class="testclass"><a href="#">Text</a></p>' }
    end
  end

  describe '#highlight' do
    let(:reservation) { create(:reservation) }
    before { allow(helper).to receive(:params).and_return({ highlight: reservation.id.to_s }) }
    subject { helper.highlight(reservation) }
    it { is_expected.to eql 'warning' }
  end
end
