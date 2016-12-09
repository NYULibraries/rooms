require 'spec_helper'

describe UsersController do

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  before { allow(controller).to receive(:current_user).and_return(admin) }

  describe 'GET /admin/users' do
    let(:q) { nil }
    before { get :index, q: q }
    subject { response }
    context 'when user is an admin' do
      context 'when there is no search term' do
        it 'should return user results' do
          expect(assigns(:users)).to_not be_empty
        end
      end
      context 'when there is a known search term' do
        let(:q) { 'Derek' }
        it 'should return user results' do
          expect(assigns(:users)).to_not be_empty
        end
      end
      context 'when there is an unknown search term' do
        let(:q) { 'schplorgadeedorf' }
        it 'should not return any user results' do
          expect(assigns(:users)).to be_empty
        end
      end
    end
    context 'when user is not an admin' do
      let(:admin) { create(:user) }
      it 'should return an access denied error' do
        expect(subject).to render_template 'user_sessions/unauthorized_action'
      end
    end
  end

  describe 'GET /admin/users/1' do
    before { get :show, id: user.to_param }
    subject { response }
    it { is_expected.to render_template(:show) }
    it 'should assign a user instance' do
      expect(assigns(:user)).to_not be_nil
      expect(assigns(:user)).to eql user
    end
  end

  describe 'GET /admin/users/new' do
    before { get :new }
    subject { response }
    it { is_expected.to render_template(:new) }
    it 'should assign a user instance' do
      expect(assigns(:user)).to_not be_nil
      expect(assigns(:user)).to be_a_new User
    end
  end

  describe 'POST /admin/users' do
    before { post :create, user: attributes_for(:user) }
    subject { response }
    it { is_expected.to have_http_status 302 }
    it 'should create a new user with the parameters passed in' do
      expect { post :create, user: attributes_for(:user) }.to change { User.count }.by(1)
    end
  end

  describe 'GET /admin/users/1/edit' do
    before { get :edit, id: user.to_param }
    subject { response }
    it { is_expected.to render_template(:edit) }
    it 'should assign a user instance' do
      expect(assigns(:user)).to_not be_nil
      expect(assigns(:user)).to eql user
    end
  end

  describe 'PATCH /admin/users/1' do
    before { patch :update, id: user.to_param, user: { admin_roles: ["superuser"] } }
    subject { response }
    it { is_expected.to redirect_to user_url(user) }
    it 'should update a new user with the parameters passed in' do
      expect(assigns(:user).is_admin?).to be true
    end
  end

  describe 'DELETE /admin/users/1' do
    let!(:user) { create(:user) }
    it 'should delete the user' do
      expect { delete :destroy, id: user.to_param }.to change { User.count }.by(-1)
    end
  end
end
