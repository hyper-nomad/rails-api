require 'api_helper'

RSpec.describe RedishAPI::Sessions do
  include ApiHelper
  include_context 'api'

  describe 'POST /sessions #Sign in' do
    let(:method){ :post }
    let(:path){ '/sessions' }

    let(:user){ User.first }

    before{ header RedishAPI::REDISH_APP_ID,  Doorkeeper::Application.first.uid  }

    describe "Header key: #{RedishAPI::REDISH_APP_ID}(application id)" do

      let(:parameters){ {email: 'user1@example.com', password: 'test1234'} }

      context 'GOOD ID' do
        before{
          user_auth = UserAuth.new :email
          allow(user_auth).to receive_messages(get_login: user)
          allow(UserAuth).to receive_messages(new: user_auth)
        }
        it{ expect(subject.status).to eq 201 }
        it{ expect(subject.body).to match_json_expression({redish_access_token: last_token}) }
        it{ expect(subject.header['Location']).to eq '/v1/users/me.json' }
      end

      context 'BAD ID' do
        before{ header RedishAPI::REDISH_APP_ID,  'bad_uid'  }
        it{ expect(subject.status).to eq 401 }
      end
    end

    describe 'authorization flow' do
      shared_examples "by authorization key" do |params|
        let(:parameters){ params }

        context "authorization OK : #{params.keys.first}" do
          context 'redish user is registered' do
            before{
              user_auth = UserAuth.new params.keys.first
              allow(user_auth).to receive_messages(get_login: user)
              allow(UserAuth).to receive_messages(new: user_auth)
            }
            it{ expect(subject.status).to eq 201 }
            it{ expect(subject.body).to match_json_expression({redish_access_token: last_token}) }
            it{ expect(subject.header['Location']).to eq '/v1/users/me.json' }
          end

          context 'redish user is not registered' do #OAuth succeed
            before{
              user_auth = UserAuth.new params.keys.first
              allow(user_auth).to receive(:get_login){
                if params.keys.first == 'email'
                  raise SignedUser::InvalidLoginInfo
                else
                  raise UnsignedUser::Unregistered
                end
              }
              allow(UserAuth).to receive_messages(new: user_auth)
            }
            it 'should return info redirect to sign up' do
              if params.keys.first == 'email'
                expect(subject.status).to eq 400
                expect(subject.body).to match_json_expression({user_messages: ['メールアドレスかパスワードが間違っています。']})
              else
                expect(subject.status).to eq 409
                expect(subject.body).to match_json_expression({error: 'Conflict'})
              end
            end
          end
        end

        context "authorization NG : #{params.keys.first}" do
          before{
            user_auth = UserAuth.new params.keys.first
            allow(user_auth).to receive(:get_login) { raise AuthProvider::NotFetchAccountOnExternalService }
            allow(UserAuth).to receive_messages(new: user_auth)
          }
          it{ expect(subject.status).to eq 401 }
        end
      end

      %w(email facebook_access_token).each{|key|
        it_behaves_like "by authorization key", {key.to_sym => 'credential value'}
      }

    end

    describe 'Exception case(short or over parameters)' do
      context 'No credential' do
        let(:parameters){ {} }

        it 'Return 400' do
          expect(subject.status).to be(400)
        end
      end

      context 'Multiple credential sets' do
        context 'GOOD (email, password) + facebook access token ' do
          let(:parameters){
            {
              email: 'user1@example.com', password: 'test1234',
              facebook_access_token: 'sometoken'
            }
          }
          it 'Return 400' do
            expect(subject.status).to be(400)
          end
        end
      end
    end
  end

  describe 'DELETE /sessions #Sign out' do
    let(:method){ :delete }
    let(:path){ '/sessions' }

    context "header[#{RedishAPI::REDISH_ACCESS_TOKEN_KEY}] is not applied" do
      it{ expect(subject.status).to eq 401 }
    end

    context 'Sign in user' do
      let(:user){ User.first }
      let(:token){ get_token user }
      before{ header RedishAPI::REDISH_ACCESS_TOKEN_KEY, token }

      it{ expect(subject.status).to eq 200 }
      it{ expect(subject.body).to match_json_expression({})}
    end

    context 'NOT sign in user' do
      let(:user){ User.first }
      let(:token){ get_token user }
      before{
        header RedishAPI::REDISH_ACCESS_TOKEN_KEY, token
        RedishOAuth::AccessToken.find(token).delete
      }

      it{ expect(subject.status).to eq 401 }
    end
  end

  def last_token
    Doorkeeper::AccessToken.last.token
  end
end
