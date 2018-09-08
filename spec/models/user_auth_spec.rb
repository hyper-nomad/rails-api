require 'rails_helper'

RSpec.describe UserAuth, :type => :model do
  describe "::initialize" do
    subject{ UserAuth.new key }

    context 'key => :email' do
      let(:key){ :email }
      it{ is_expected.to be_a(AuthProvider::IPass) }
      it{ is_expected.to respond_to(:get_login).with(1).argument }
    end

    context 'key => :facebook_access_token' do
      let(:key){ :facebook_access_token }
      it{ is_expected.to be_a(AuthProvider::FacebookOAuth) }
      it{ is_expected.to respond_to(:get_login).with(1).argument }
    end

    context 'key is invalid value' do
      let(:key){ :unknown_type }
      it "should raise argument error" do
        expect{ subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#get_login' do
  end
end
