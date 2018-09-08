require 'rails_helper'

RSpec.describe RedishOAuth, :type => :model do
  let(:app){ Doorkeeper::Application.first }
  let(:user){ User.first }
  let(:registered_token){ RedishOAuth::AccessToken.generate app, user }

  describe '::authenticated_user' do
    subject{ RedishOAuth.authenticated_user token }

    context 'OK token' do
      let(:token){ registered_token.token }
      it{ is_expected.to eq user }
    end

    context 'NG token(token not registered)' do
      let(:token){ registered_token.token.reverse }

      it 'should NOT raise error' do
        expect{ subject }.to_not raise_error
      end

      it{ is_expected.to be_nil }
    end

    context 'NG token(token is revoked)' do
      before{ registered_token.update(revoked_at: Time.now) }
      let(:token){ registered_token.token }

      it 'should NOT raise error' do
        expect{ subject }.to_not raise_error
      end

      it{ is_expected.to be_nil }
    end

    context 'NG the user is not exists' do
      before{
        expect(registered_token).to be_present
        user.delete
      }
      let(:token){ registered_token.token }
      it 'should NOT raise error' do
        expect{ subject }.to_not raise_error
      end

      it{ is_expected.to be_nil }
    end
  end

  describe "::AccessToken" do
    describe "::generate" do
      subject{ RedishOAuth::AccessToken.generate app, user }

      context 'GOOD app & user' do

        it{ is_expected.to be_a(Doorkeeper::AccessToken) }
        it{ expect(subject.token).to be_present }
        it{ expect(subject.token).to eq Doorkeeper::AccessToken.first.token }

        context 'exist already token' do
          before{
            @exists_token =
              Doorkeeper::AccessToken.find_or_create_for app, user.id, [], nil, false
          }

          it 'should return new token' do
            expect(subject).to_not eq @exists_token
          end
        end
      end
    end

    describe '::find' do
      subject{ RedishOAuth::AccessToken.find token }

      context 'GOOD token' do
        let(:token){ registered_token.token }
        it{ is_expected.to eq registered_token }
      end

      context 'GOOD token but revoked' do
        before{
          registered_token.update(revoked_at: Time.now)
          expect(registered_token.reload.revoked_at).to be_present
        }
        let(:token){ registered_token.token }
        it{ is_expected.to eq registered_token }
      end

      context 'BAD token (not exists) ' do
        let(:token){ 'bad_token' }
        it 'should raise UserAuth::UnauthorizedError' do
          expect{ subject }.to raise_error UserAuth::UnauthorizedError
        end
      end
    end
  end
end
