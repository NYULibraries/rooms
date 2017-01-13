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
    let!(:room_group) { create(:room_group) }
    before { get :new }
    subject { response }
    it { is_expected.to render_template :new }
    it 'should load a room instance' do
      expect(assigns(:room)).to be_a_new Room
    end
    it 'should load all the room groups' do
      expect(assigns(:room_groups)).to_not be_empty
    end
  end

  describe 'POST /admin/rooms' do
    before { post :create, room: room_params, opens_at: opens_at, closes_at: closes_at }
    subject { response }
    it { is_expected.to redirect_to room_url(assigns(:room).id) }
    it 'should create a new room' do
      expect(assigns(:room).title).to eql title
      expect(assigns(:room).type_of_room).to eql type_of_room
      expect(assigns(:room).collaborative).to be true
      expect(assigns(:room).description).to eql description
      expect(assigns(:room).image_link).to eql image_link
      expect(assigns(:room).opens_at).to eql " 7:00"
      expect(assigns(:room).closes_at).to eql " 7:00"
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
    before { patch :update, id: room.id, room: { title: title }, opens_at: opens_at, closes_at: closes_at }
    subject { response }
    it { is_expected.to redirect_to room_url(assigns(:room).id) }
    it 'should update an existing room' do
      expect(assigns(:room)).to be_a Room
      expect(assigns(:room).title).to eql title
      expect(flash[:success]).to eql I18n.t('rooms.update.success')
    end
  end

  describe 'DELETE /admin/rooms/1' do
    let!(:room) { create(:room) }
    it 'should delete the room' do
      expect { delete :destroy, id: room.to_param }.to change { Room.count }.by(-1)
    end
  end

  describe 'GET /admin/rooms/sort' do
    before { get :index_sort }
    subject { response }
    it { is_expected.to render_template(:index_sort) }
    it 'should assign a user instance' do
      expect(assigns(:rooms)).to_not be_empty
    end
  end

  describe 'PATCH /admin/rooms/update_sort' do
    before(:all) do
      @room_one    = create(:room, title: "Room 1")
      @room_two    = create(:room, title: "Room 2")
      @room_three  = create(:room, title: "Room 3")
    end
    before { patch :update_sort, rooms: [@room_two.id, @room_one.id, @room_three.id] }
    subject { response }
    it 'should resort all rooms' do
      expect(Room.find(@room_one.id).sort_order).to eql 2
      expect(Room.find(@room_two.id).sort_order).to eql 1
      expect(Room.find(@room_three.id).sort_order).to eql 3
    end
  end

end
