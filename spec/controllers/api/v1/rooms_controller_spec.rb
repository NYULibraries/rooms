require 'rails_helper'

describe Api::V1::RoomsController do

  describe 'GET /api/v1/rooms' do
    before { create(:room) }
    before { get :index, format: :json }
    describe 'response return status' do
      subject { response }
      it { is_expected.to have_http_status 200 }
    end
    describe 'response content type' do
      subject { response.header['Content-Type'] }
      it { is_expected.to include 'application/json' }
    end
    describe 'json response' do
      let(:index) { '0' }
      subject { response.body }
      context 'when there are rooms' do
        it { is_expected.to have_json_path("#{index}/id") }
        it { is_expected.to have_json_path("#{index}/sort_order") }
        it { is_expected.to have_json_path("#{index}/title") }
        it { is_expected.to have_json_path("#{index}/description") }
        it { is_expected.to have_json_path("#{index}/type_of_room") }
        it { is_expected.to have_json_path("#{index}/size_of_room") }
        it { is_expected.to have_json_path("#{index}/image_link") }
        it { is_expected.to have_json_path("#{index}/hours") }
        it { is_expected.to have_json_path("#{index}/sort_size_of_room") }
        it { is_expected.to have_json_path("#{index}/opens_at") }
        it { is_expected.to have_json_path("#{index}/closes_at") }
        it { is_expected.to have_json_path("#{index}/room_group") }
      end
    end
  end

end
