require 'rails_helper'

describe RoomsController do

  before(:all) do
    @existing_room = create(:room)
    Room.import
    sleep 3
  end
  let(:opens_at) do
     {
      :hour => '7',
      :minute => '0',
      :ampm => 'am'
    }
  end
  let(:closes_at) do
    {
      :hour => '7',
      :minute => '0',
      :ampm => 'am'
    }
  end
  let(:title) { 'LL1-01' }
  let(:type_of_room) { 'Graduate Study' }
  let(:collaborative) { '1' }
  let(:description) { 'yadda yadda' }
  let(:size_of_room) { '1 person' }
  let(:image_link) { 'http://localhost/1.png' }
  let(:room_params) do
    {
      room_group_id: create(:room_group).to_param,
      title: title,
      type_of_room: type_of_room,
      collaborative: collaborative,
      description: description,
      size_of_room: size_of_room,
      image_link: image_link
    }
  end
  let(:room) { create(:room) }
  let(:user) { create(:admin) }
  before { allow(controller).to receive(:current_user).and_return(user) }

  describe 'GET /admin/rooms' do
    let(:q) { nil }
    before { get :index, q: q }
    subject { response }

    context 'when user is an admin' do
      context 'when there is no search term' do
        it 'should return room results' do
          expect(assigns(:rooms)).to_not be_empty
        end
      end
      context 'when there is a known search term' do
        let(:q) { 'Room 1' }
        it 'should return room results' do
          expect(assigns(:rooms)).to_not be_empty
        end
      end
      context 'when there is an unknown search term' do
        let(:q) { 'schplorgadeedorf' }
        it 'should not return any room results' do
          expect(assigns(:rooms)).to be_empty
        end
      end
    end
    context 'when user is not an admin' do
      let(:user) { create(:user) }
      it 'should return an access denied error' do
        expect(subject).to render_template 'user_sessions/unauthorized_action'
      end
    end
  end

  describe 'GET /admin/rooms/1' do
    before { get :show, id: room.id }
    it { is_expected.to render_template :show }
    it 'should load a room instance' do
      expect(assigns(:room)).to be_a Room
    end
  end

  describe 'GET /admin/rooms/new' do
    before { get :new }
    subject { response }
    it { is_expected.to render_template :new }
    it 'should load a room instance' do
      expect(assigns(:room)).to be_a_new Room
    end
    context "when user is a global admin" do

    end
    context "when user is a ny admin" do
      let(:user) { create(:ny_admin) }

    end
    context "when user is a shanghai admin" do
      let(:user) { create(:shanghai_admin) }

    end
  end

  describe 'POST /admin/rooms' do
    before { post :create, room: room_params, opens_at: opens_at, closes_at: closes_at }
    subject { response }
    it { is_expected.to redirect_to '' }
    it 'should create a new room' do
      expect(assigns(:room)).to eql ''
    end
  end

  describe 'GET /admin/rooms/1/edit' do
    before { get :edit, id: room.id }
    subject { response }
    it { is_expected.to render_template :edit }
    it 'should load the existing room' do
      expect(assigns(:room)).to eql room
    end
  end

  describe 'PATCH /admin/rooms/1' do
    let(:title) { 'a new title' }
    before { patch :update, id: room.id, room: { title: title }, opens_at: room.opens_at, closes_at: room.closes_at }
    subject { response }
    it { is_expected.to redirect_to room_url(assigns(:room).id) }
    it 'should update an existing room' do
      expect(assigns(:room)).to be_a Room
      expect(assigns(:room).title).to eql title
      expect(flash[:notice]).to eql I18n.t('rooms.update.success')
    end
  end

  describe 'GET /admin/rooms/sort' do

  end

  describe 'PATCH /admin/rooms/update_sort' do

  end

end
