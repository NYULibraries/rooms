require "rails_helper"

describe LayoutsHelper do

  describe '#application_javascript' do
    subject { helper.application_javascript }
    it { should include '<script src="/assets/' }
  end

  describe '#google_analytics?' do
    subject { helper.google_analytics? }
    it { should be false }
  end

  describe '#google_analytics_tracking_code' do
    subject { helper.google_analytics_tracking_code }
    it 'should not raise an error' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#google_tag_manager?' do
    subject { helper.google_tag_manager? }
    it { should be false }
  end

  describe '#google_tag_manager_tracking_code' do
    subject { helper.google_tag_manager_tracking_code }
    it 'should not raise an error' do
      expect { subject }.not_to raise_error
    end
  end

end
