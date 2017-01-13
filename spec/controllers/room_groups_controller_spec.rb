require 'rails_helper'

describe RoomGroupsController do

  let(:admin) { create(:admin) }
  let!(:room_group) { create(:room_group) }
  before { allow(controller).to receive(:current_user).and_return(admin) }

  describe 'GET /admin/room_groups' do
    before { get :index }
    subject { response }

    context 'when user is an admin' do
      it 'should return room groups' do
        expect(assigns(:room_groups)).to_not be_empty
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

  describe 'GET /admin/room_groups/1' do
    before { get :show, id: room_group.to_param }
    subject { response }
    it { is_expected.to render_template :show }
    it 'should show a room group' do
      expect(assigns(:room_group)).to_not be_nil
    end
  end

  describe 'GET /admin/room_groups/new' do
    before { get :new }
    subject { response }
    it { is_expected.to render_template :new }
    it 'should instantiate a new room group' do
      expect(assigns(:room_group)).to be_a_new RoomGroup
    end
  end

  describe 'POST /admin/room_groups' do
    before { post :create, room_group: attributes_for(:room_group, admin_roles: ['superuser']) }
    subject { response }
    it { is_expected.to redirect_to room_group_url(assigns(:room_group).id) }
    it 'should create a new room group' do
      expect(assigns(:room_group)).to be_a RoomGroup
      expect(flash[:success]).to eql I18n.t('room_groups.create.success')
    end
  end

  describe 'GET /admin/room_groups/1/edit' do
    before { get :edit, id: room_group.id }
    subject { response }
    it { is_expected.to render_template :edit }
    it 'should load the existing room group' do
      expect(assigns(:room_group)).to eql room_group
    end
  end

  describe 'PATCH /admin/room_groups/1' do
    let(:title) { 'a new title' }
    before { patch :update, id: room_group.id, room_group: { title: title } }
    subject { response }
    it { is_expected.to redirect_to room_group_url(assigns(:room_group).id) }
    it 'should create a new room group' do
      expect(assigns(:room_group)).to be_a RoomGroup
      expect(assigns(:room_group).title).to eql title
      expect(flash[:success]).to eql I18n.t('room_groups.update.success')
    end
  end

  describe 'DELETE /admin/room_groups/1' do
    it 'should delete the room groups' do
      expect { delete :destroy, id: room_group.to_param }.to change { RoomGroup.count }.by(-1)
    end
  end

end
