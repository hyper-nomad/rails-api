require 'api_helper'

RSpec.describe RedishAPI::AppDevices do
  include ApiHelper
  include_context 'api'

  describe 'POST /app_devices' do
    let(:method) { :post }
    let(:path) { "/app_devices" }
    let(:parameters){ {token: 'a_device_token', app_version: '1.0.0'} }

    let(:user){ User.first }
    let(:token){ get_token user }

    context 'not have application token header' do
      it{ expect(subject.status).to eq 401 }
    end

    context 'invalid application token' do
      before{ header RedishAPI::REDISH_APP_ID, 'bad_token' }
      it{ expect(subject.status).to eq 401 }
    end

    context 'not set app_version' do
      let(:parameters){ {token: 'a_device_token' } }
      it{ expect(subject.status).to eq 400 }
    end

    context 'set app_version' do
      it{ expect(subject.status).to eq 201 }
      before{ header RedishAPI::REDISH_APP_ID, 'ios_app_id_on_test' }

      it 'should register parameter app_version info' do
        subject
        expect(AppDevice.first.version).to eq '1.0.0'
      end
    end

    context 'valid access token' do
      let(:iOS_token){ 'ios_app_id_on_test' }
      let(:android_token){ 'android_app_id_on_test' }

      before{ header RedishAPI::REDISH_APP_ID, iOS_token }

      context 'parameter(device token) is NOT set' do
        let(:parameters){ }
        it{ expect(subject.status).to eq 400 }
      end

      context 'parameter(device token) is set' do
        it{ expect(subject.status).to eq 201 }
      end

      describe 'application type' do
        context 'client application is iOS' do
          it 'should register IOsDevice' do
            subject
            expect(AppDevice.first.class).to eq IOsDevice
          end
        end

        context 'client application is Android' do
          before{ header RedishAPI::REDISH_APP_ID, android_token }
          it 'should register AndroidDevice' do
            subject
            expect(AppDevice.first.class).to eq AndroidDevice
          end
        end
      end

      context 'the token is not registered yet' do
        before{ expect(AppDevice.count).to eq 0}
        it 'should register AppDivice' do
          subject
          expect(AppDevice.count).to eq 1
          expect(AppDevice.first.token).to eq parameters[:token]
        end
      end

      context 'the token is already registerd' do
        let(:already_exist){ IOsDevice.create token: 'a_device_token', updated_at: 1.minute.ago }
        before{
          already_exist
          expect(AppDevice.count).to eq 1
        }

        it 'should update already exists token record' do
          subject
          expect(AppDevice.count).to eq 1
          expect(AppDevice.first.updated_at).to be > already_exist.updated_at
        end

        context 'already registered data DOES NOT have user_id' do
          before{
            already_exist
            expect(AppDevice.count).to eq 1
            expect(AppDevice.first.user).to be_nil
          }

          context 'new registration has user_token' do
            before{ header RedishAPI::REDISH_ACCESS_TOKEN_KEY, token }

            it 'should update already exists and set user_id' do
              subject
              expect(AppDevice.count).to eq 1
              expect(AppDevice.first.user_id).to eq user.id
            end
          end
        end

        context 'already registered data has a user_id' do
          before{
            already_exist.update(user_id: user.id, updated_at: 1.second.ago)
            already_exist.reload
          }
          context 'new registration DOES NOT have user_token' do
            it 'update timestamp BUT not overwrite user_id' do
              subject
              expect(AppDevice.count).to eq 1
              expect(AppDevice.first.user_id).to eq user.id
              expect(AppDevice.first.updated_at).to be > already_exist.updated_at
            end
          end

          context "new registration has other user's token" do
            before{ header RedishAPI::REDISH_ACCESS_TOKEN_KEY, get_token(SignedUser.last) }
            it 'update timestamp BUT not overwrite user_id' do
              subject
              expect(AppDevice.count).to eq 1
              expect(AppDevice.first.user_id).to eq user.id
              expect(AppDevice.first.updated_at).to be > already_exist.updated_at
            end
          end
        end
      end
    end
  end

  describe 'GET /latest' do
    let(:method) { :get }
    let(:path) { "/app_devices/latest" }
    let(:parameters){ {} }

    context 'not have application token header' do
      it{ expect(subject.status).to eq 401 }
    end

    context 'invalid application token' do
      before{ header RedishAPI::REDISH_APP_ID, 'bad_token' }
      it{ expect(subject.status).to eq 401 }
    end

    context 'valid application token' do
      before{ header RedishAPI::REDISH_APP_ID, 'ios_app_id_on_test' }
      it{ expect(subject.status).to eq 200 }
      it{ expect(subject.body).to match_json_expression({
                                                          name:'iOS app on test',
                                                          uid: 'ios_app_id_on_test',
                                                          latest: '0.0.1'
                                                        }.strict!) }
    end
  end
end
