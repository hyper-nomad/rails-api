require 'rails_helper'

RSpec.describe DeviseUsers::ConfirmationsController, :type => :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'GET show' do
    subject{ get :show, {confirmation_token: token}}

    context "For webview" do
      before do
        allow_any_instance_of(DeviseUsers::ConfirmationsController).to receive_messages(as_webview?: true)
      end
      context 'valid token' do
        let(:user){ User.first }
        let(:new_email){ 'new_email@example.com' }
        let(:token){ confirmation_token_by_email(%r(/users/confirmation\?confirmation_token=([^"]+))) }
        before do
          ActionMailer::Base.deliveries.clear
          user.update!(email: new_email)
        end
        it 'empty errors' do
          subject
          expect(assigns(:errors).empty?).to be_truthy
        end
      end
      context 'invalid token' do
        let(:token){'invalid token'}
        it 'should receive a error message' do
          subject
          expect(assigns(:errors).full_messages).to eq ['確認トークンは不正な値です。']
        end
      end
    end
    context "No webview" do
      pending
    end
  end
end
