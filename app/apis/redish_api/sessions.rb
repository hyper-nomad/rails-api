module RedishAPI
  class Sessions < Grape::API
    resource :sessions do
      desc "Sign in",
           headers: Document.request_headers(REDISH_APP_ID),
           detail: I18n.t(:sign_in, scope: [:api, :doc, :sessions]),
           entity: Grape::Entity,
           http_codes: I18n.t([:created, :unauthorized, :bad_request], scope: :sc)
      params do
        optional :email, type: String, desc: 'Email Address'
        optional :password, type: String, desc: 'Password for email address'
        optional :facebook_access_token, type: String, desc: 'Facebook Access Token'
        exactly_one_of :email, :facebook_access_token
      end
      post '/' do
        redish_error! :unauthorized unless redish_app
        begin
          user = UserAuth.new(login_key).get_login(params)
        rescue AuthProvider::NotFetchAccountOnExternalService
          redish_error! :unauthorized
        rescue UnsignedUser::Unregistered
          redish_error! :conflict
        rescue SignedUser::InvalidLoginInfo
          redish_error! :bad_request, :"error.sign_in.invalid_account"
        end
        response_token user
      end


      desc "Sign out",
           headers: { REDISH_ACCESS_TOKEN_KEY => { description: 'Redish Access Token', required: true }},
           detail: I18n.t(:sign_out, scope: [:api, :doc, :sessions]),
           entity: Grape::Entity,
           http_codes: I18n.t([:ok, :unauthorized], scope: :sc)
      delete '/' do
        authenticate!
        RedishOAuth::AccessToken.find(headers[REDISH_ACCESS_TOKEN_KEY]).destroy
        {}
      end
    end
  end
end
