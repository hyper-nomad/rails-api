require 'rails_helper'

RSpec.describe AuthProvider, :type => :model do
  let(:obj){ Object.new }
  let(:now){ Time.parse('2015-02-05 12:00:00') }

  before do
    allow(Time).to receive_messages(now: now)
  end

  describe AuthProvider::IPass do
    before{ obj.extend AuthProvider::IPass }

    describe '#get_login' do

      let(:credential){ {email: 'user1@example.com', password: 'test1234'} }
      subject{ obj.get_login credential }

      it "should call User.ipass_authenticate" do
        expect(SignedUser).to receive(:ipass_authenticate).
                         with('user1@example.com', 'test1234').
                         and_return(SignedUser.new)
        subject
      end

      context 'valid credential' do
        it{ is_expected.to be_a SignedUser }
        it{ is_expected.to eq SignedUser.find_by_email(credential[:email]) }
      end

      context 'invalid credential' do
        let(:credential){ {email: 'user1@example.com', password: 'test'} }
        it{ expect{ subject }.to raise_error SignedUser::InvalidLoginInfo }
      end

      context 'credential does NOT include :email and password' do
        let(:credential){ {hoge: 123} }
        it{ expect{ subject }.to raise_error SignedUser::InvalidLoginInfo }
      end
    end
    describe "#sign_up_user" do
      pending
    end
  end


  describe AuthProvider::FacebookOAuth do
    before{ obj.extend AuthProvider::FacebookOAuth }
    describe '#get_login' do

      let(:credential){ {facebook_access_token: 'token'} }
      subject{ obj.get_login credential }

      let(:koala){ Koala::Facebook::API.new 'aaatoken'}
      let(:user){ User.first }


      context 'facebook login fail' do
        it 'should raise error' do
          expect{ subject }.to raise_error AuthProvider::NotFetchAccountOnExternalService
        end
      end

      context 'facebook login success' do
        before{
          allow(koala).to receive_messages(get_object: {'id' => '232323'})
          allow(Koala::Facebook::API).to receive_messages(new: koala)
        }
        context 'redish user is registered' do
          let(:login_account){
            LoginAccount.create(
              provider: 'facebook',
              uid: '232323',
              user_id: user.id,
              updated_at: Time.parse('2015-02-04 12:00:00')
            )
          }
          before{
            login_account
          }

          it{ is_expected.to eq user }
          it{ expect(subject.login_accounts.first.provider).to eq 'facebook' }
          it{ expect(subject.login_accounts.first.updated_at).to eq now }
        end

        context 'redish user is NOT registered' do
          it{ expect{ subject }.to raise_error UnsignedUser::Unregistered }
        end
      end
    end
    describe "#sign_up_user" do
      pending
    end
  end
end
