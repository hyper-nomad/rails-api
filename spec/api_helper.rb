require 'rails_helper'
require 'json_expressions/rspec'

module ApiHelper
  # for http methods DSL (get, post...)
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def get_token user
    app = Doorkeeper::Application.first
    RedishOAuth::AccessToken.generate(app, user).token
  end

  shared_context 'api' do
    subject { request }
    let(:request) { eval("#{method}(endpoint, parameters)") }
    let(:version) { '/api/v1' }
    let(:endpoint) { version + path }
    let(:parameters) { {} }
  end
  shared_examples_for 'status_code_and_response_body' do
    let(:status_code){ nil }
    let(:result){ nil }

    context "Status Code" do
      subject { request.status }
      it { is_expected.to eq status_code }
    end
    context "Response Body" do
      subject { request.body }
      it { is_expected.to match_json_expression(result) }
    end
  end

  shared_examples_for 'Redish access token authorization' do
    context 'Request header does NOT include redish access token key' do
      before{ request.header.delete RedishAPI::REDISH_ACCESS_TOKEN_KEY }

      it_behaves_like 'status_code_and_response_body' do
        let(:status_code){ 401 }
        let(:result){ {"error"=>"Unauthorized"} }
      end
    end

    context 'Request header include redish access token key BUT token is invalid' do
      before{ header RedishAPI::REDISH_ACCESS_TOKEN_KEY, 'bad_token' }

      it_behaves_like 'status_code_and_response_body' do
        let(:status_code){ 401 }
        let(:result){ {"error"=>"Unauthorized"} }
      end
    end
  end
end
