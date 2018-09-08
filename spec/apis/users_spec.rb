require 'api_helper'

RSpec.describe RedishAPI::Users do
  include ApiHelper
  include_context 'api'

  shared_examples_for "Send confirmation mail" do |type|
    before do
      ActionMailer::Base.deliveries.clear
    end
    it "should send a confirmation mail with valid token" do
      subject
      expect(ActionMailer::Base.deliveries.size).to eq 1
      regexp = if type == :reconfirmation
                 %r(/users/confirmation\?confirmation_token=([^"]+))
               else
                 %r(redish://confirmation\?confirmation_token=([^\<]+))
               end
      token = confirmation_token_by_email(regexp)
      expect(SignedUser.confirm_by_token(token).errors.blank?).to be_truthy
    end
  end

  let(:token){ get_token user }

  describe 'GET /users/me' do
    let(:method){ :get }
    let(:path){ "/users/me" }

    it_behaves_like 'Redish access token authorization'
    context "OK: a user has a coupon book of trial edition" do
      let(:user){ FactoryGirl.create(:user) }

      before{ header RedishAPI::REDISH_ACCESS_TOKEN_KEY, token }
      it_behaves_like "status_code_and_response_body" do
        let(:status_code){ 200 }
        let(:result) do
          {
            email: user.email,
            registration_status: "registered",
          }
        end
      end
    end
  end

  describe 'POST /users' do
    let(:method){ :post }
    let(:path){ "/users" }

    before{ header RedishAPI::REDISH_APP_ID,  Doorkeeper::Application.first.uid  }

    context "Header key: #{RedishAPI::REDISH_APP_ID}(application id)" do
      let(:parameters){ { facebook_access_token: 'xxxtokenxxx' } }

      before do
        allow_any_instance_of(AuthProvider::FacebookOAuth).to receive(:me){ {'id' => '323232' } }
        allow_any_instance_of(AuthProvider::FacebookOAuth).to receive(:account_info) do
          {
            'provider' => '',
            'uid'      => '',
            'info'     => {},
            'credentials' => {},
            'extra' => {}
          }
        end
      end

      context 'GOOD ID' do
        it{ expect(subject.status).to eq 201 }
        it{ expect(subject.body).to match_json_expression({redish_access_token: last_token}) }
        it{ expect(subject.header['Location']).to eq '/v1/users/me.json' }
      end

      context 'BAD ID' do
        before{ header RedishAPI::REDISH_APP_ID,  'bad_uid'  }
        it{ expect(subject.status).to eq 401 }
      end
    end

    context 'IPass' do
      let(:email){ 'not_existed@example.com' }
      let(:password){ 'test1234' }
      let(:password_confirmation){ 'test1234' }
      let(:parameters) do
        {
          email: email,
          password: password,
          password_confirmation: password_confirmation
        }
      end
      context "OK" do
        it_behaves_like "status_code_and_response_body" do
          let(:status_code){ 201 }
          let(:result){ {redish_access_token: last_token} }
        end
        it{ expect(subject.header['Location']).to eq '/v1/users/me.json' }
      end
      context "NG" do
        context "User existed" do
          let(:email){ 'user1@example.com' }

          it_behaves_like "status_code_and_response_body" do
            let(:status_code){ 409 }
            let(:result){ { error: 'Conflict'} }
          end
        end
        context "User existed(email alias)" do
          before do
            SignedUser.create!(email: 'already@gmail.com')
          end
          let(:email){ 'alr.ea.dy@gmail.com' }

          it_behaves_like "status_code_and_response_body" do
            let(:status_code){ 400 }
            let(:result){ { user_messages: ['すでに登録されたメールアドレスです。']} }
          end
        end
        context "Invalid password length" do
          let(:password){ 'short' }
          let(:password_confirmation){ 'short' }

          it_behaves_like "status_code_and_response_body" do
            let(:status_code){ 400 }
            let(:result){ { user_messages: ['パスワードは8文字以上で入力してください。'] } }
          end
        end
        context "Invalid password confirmation" do
          let(:password){ 'test1234' }
          let(:password_confirmation){ 'test4321' }

          it_behaves_like "status_code_and_response_body" do
            let(:status_code){ 400 }
            let(:result){ { user_messages: ['確認パスワードとパスワードの入力が一致しません。'] } }
          end
        end
      end
    end
    context 'Facebook' do
      let(:parameters){ { facebook_access_token: 'xxxtokenxxx' } }

      before do
        allow_any_instance_of(AuthProvider::FacebookOAuth).to receive(:me){ mock_me }
        allow_any_instance_of(AuthProvider::FacebookOAuth).to receive(:account_info){
          {
            'provider' => 'facebook',
            'uid'      => '323232',
            'info'     => {
              'email' => 'dummy@example.com',
              'name'  => 'dummy',
              'image' => 'http://example.com/icon',
            },
            'credentials' => {
              'token' => parameters[:facebook_access_token]
            },
            'extra' => {}
          }
        }
      end
      context 'OK' do
        let(:mock_me){ {'id' => '323232'} }
        it_behaves_like "status_code_and_response_body" do
          let(:status_code){ 201 }
          let(:result){ {redish_access_token: last_token} }
        end
        it{ expect(subject.header['Location']).to eq '/v1/users/me.json' }
        it "should user && login account created" do
          subject
          account = UnsignedUser.last.login_accounts.last
          expect(account.uid).to eq '323232'
          expect(account.access_token).to eq 'xxxtokenxxx'
        end
      end
      context 'Can NOT fetch social account id' do
        let(:mock_me){ nil }
        it_behaves_like "status_code_and_response_body" do
          let(:status_code){ 401 }
          let(:result){ { error: 'Unauthorized' } }
        end
      end
      context 'Conflict login account' do
        let(:mock_me){ {'id' => '323232'} }
        before do
          FactoryGirl.create(:facebook_account, access_token: 'xxxtokenxxx', uid: '323232')
        end
        it_behaves_like "status_code_and_response_body" do
          let(:status_code){ 409 }
          let(:result){ { error: 'Conflict'} }
        end
      end
    end
  end

  describe 'PUT /users' do
    let(:method){ :put }
    let(:path){ "/users" }

    let(:user){ SignedUser.first }

    context "Password" do
      let(:parameters){ {password: password,
                         password_confirmation: password_confirmation,
                         current_password: current_password } }

      let(:password)             { 'testtest' }
      let(:password_confirmation){ 'testtest' }
      let(:current_password)     { 'current_password' }

      before do
        user.update!(password: 'current_password', password_confirmation: 'current_password')
      end

      it_behaves_like 'Redish access token authorization'

      context "Valid redish access token" do
        before do
          header RedishAPI::REDISH_ACCESS_TOKEN_KEY, token
        end
        context "OK" do
          it_behaves_like "status_code_and_response_body" do
            let(:status_code){ 200 }
            let(:result) do
              {
                email: user.email,
                registration_status:"registered",
              }
            end
          end
          it 'should changed password' do
            subject
            user.reload
            expect(SignedUser.ipass_authenticate(user.email, password)).to eq user
          end
        end
        context "Validation Error" do
          shared_examples_for "invalid parameters" do
            it_behaves_like "status_code_and_response_body" do
              let(:status_code){ 400 }
              let(:result){ { user_messages: [result_user_message] } }
            end
          end
          context "Invalid current password" do
            let(:password)             { 'testtest' }
            let(:password_confirmation){ 'testtest' }
            let(:current_password)     { 'no_current_password' }
            let(:result_user_message)  { '現在のパスワードは不正な値です。' }

            it_behaves_like 'invalid parameters'
          end
          context "Invalid password length" do
            let(:password)             { 'short' }
            let(:password_confirmation){ 'short' }
            let(:current_password)     { 'current_password' }
            let(:result_user_message)  { 'パスワードは8文字以上で入力してください。' }

            it_behaves_like 'invalid parameters'
          end
          context "Invalid password confirmation" do
            let(:password)             { 'testtest1' }
            let(:password_confirmation){ 'testtest2' }
            let(:current_password)     { 'current_password' }
            let(:result_user_message)  { '確認パスワードとパスワードの入力が一致しません。' }

            it_behaves_like 'invalid parameters'
          end
        end
      end
    end

    context "Email" do
      let(:parameters){ {email: new_email} }
      let(:new_email){ 'new_email@example.com' }

      it_behaves_like 'Redish access token authorization'

      context "Valid redish access token" do
        let(:user){ SignedUser.first }
        before do
          header RedishAPI::REDISH_ACCESS_TOKEN_KEY, token
        end
        context "OK" do
          it_behaves_like "status_code_and_response_body" do
            let(:status_code){ 200 }
            let(:result) do
              {
                email: user.email,
                registration_status:"registered",
              }.forgiving!
            end
          end

          it_behaves_like 'Send confirmation mail', :reconfirmation

          context "same email" do
            let(:new_email){ 'user1@example.com' }
            it_behaves_like "status_code_and_response_body" do
              let(:status_code){ 400 }
              let(:result){ { user_messages: ['同じメールアドレスです。']} }
            end
          end
        end
        context "Validation Error" do
          context "already existed email" do
            before do
              SignedUser.create!(email: 'already@gmail.com')
            end
            let(:new_email){ 'alread.y@gmail.com' }
            it_behaves_like "status_code_and_response_body" do
              let(:status_code){ 409 }
              let(:result){ { user_messages: ['すでに登録されたメールアドレスです。']} }
            end
          end
        end
      end
    end
  end

  def last_token
    Doorkeeper::AccessToken.last.token
  end

end
