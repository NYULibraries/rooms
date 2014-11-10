require 'spec_helper'

describe RoomsController do

  let(:user) { create(:admin) }
  before(:each) { controller.stub(:current_user).and_return(user) }

  describe 'GET /rooms/new' do
    before { get :index }
    subject { assigns(:rooms) }
    context "when user is a global admin" do

    end
    context "when user is a ny admin" do
      let(:user) { create(:ny_admin) }

    end
    context "when user is a shanghai admin" do
      let(:user) { create(:shanghai_admin) }

    end
  end

  describe 'POST /rooms' do

  end

  describe 'GET /rooms' do

  end

  describe 'GET /rooms/1' do

  end

  describe 'GET /rooms/1/edit' do

  end

  describe 'PUT /rooms/1' do

  end

  describe 'GET /rooms/sort' do

  end

  describe 'PUT /rooms/update_sort' do

  end

end
