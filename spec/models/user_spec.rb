require 'rails_helper'

describe User do
  let(:username) { Faker::Internet.user_name }
  let(:email) { Faker::Internet.email }
  let(:provider) { 'nyulibraries' }
  let(:user) { User.new(username: username, email: email, provider: provider) }

  describe '.new' do
    let(:rooms_default_admins) { [username] }
    before { allow(Figs.env).to receive(:rooms_default_admins).and_return(rooms_default_admins) }
    before { user.save }
    subject { user.admin_roles }

    context 'when username is included in list of static superusers' do
      it { is_expected.to include 'superuser' }
    end
    context 'when username is not included in list of status superusers' do
      let(:rooms_default_admins) { [] }
      it { is_expected.to_not include 'superuser' }
    end
  end
end
