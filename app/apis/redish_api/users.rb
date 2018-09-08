module RedishAPI
  class Users < Grape::API
    resource :users do
      desc "Show own user",
        headers: Document.request_headers(REDISH_ACCESS_TOKEN_KEY),
        detail: I18n.t(:show, scope: [:api, :doc, :users],
                      redish_access_token: Document.redish_access_token),
        entity: Grape::Entity,
        http_codes: [
          *I18n.t([:ok, :unauthorized], scope: :sc),
        ]
      get '/me' do
        redish_error! :unauthorized unless current_user
        present current_user.decorate, with: Entities::User
      end

      desc "Sign up user",
        headers: Document.request_headers(REDISH_APP_ID),
        detail: I18n.t(:sign_up, scope: [:api, :doc, :users]),
        entity: Grape::Entity,
        http_codes: [
          *I18n.t([:created, :invalid_parameter, :unauthorized, :conflict], scope: :sc),
        ]
      params do
        optional :email, type: String, desc: 'Email Address'
        optional :password, type: String, desc: 'Password'
        optional :password_confirmation, type: String, desc: 'Password Confirmation'
        optional :facebook_access_token, type: String, desc: 'Facebook Access Token'
        exactly_one_of :email, :facebook_access_token
        all_or_none_of :email, :password, :password_confirmation
      end
      post '/' do
        redish_error! :unauthorized unless redish_app

        begin
          user = UserAuth.new(login_key).sign_up_user(params)
        rescue AuthProvider::NotFetchAccountOnExternalService
          redish_error! :unauthorized
        rescue SignedUser::PersistedError, UnsignedUser::LoginAccountPersistedError
          redish_error! :conflict
        end

        begin
          user.save!
        rescue ActiveRecord::RecordInvalid => e
          redish_error! :invalid_parameter, *e.record.errors.full_messages
        end

        response_token user
      end

      desc "Edit user information",
        headers: Document.request_headers(REDISH_ACCESS_TOKEN_KEY),
        detail: I18n.t(:edit, scope: [:api, :doc, :users]),
        entity: Grape::Entity,
        http_codes: [
          *I18n.t([:ok, :invalid_parameter, :unauthorized], scope: :sc),
        ]
      params do
        optional :email,                 type: String, desc: 'New Email Address'
        optional :password,              type: String, desc: 'New Password'
        optional :password_confirmation, type: String, desc: 'New Password Confirmation'
        optional :current_password,      type: String, desc: 'Current Password'
        exactly_one_of :email, :password
        all_or_none_of :password, :password_confirmation, :current_password
      end
      put '/' do
        authenticate!

        # moduleを一枚挟む実装にしたい
        case key_from_params %w(email password)
        when :email
          if current_user.naked_email == NakedEmail.new(params[:email])
            redish_error! :bad_request, :'error.email.same_email'
          end
          current_user.email = params[:email]
          current_user.save

          # きたない、、
          if current_user.errors.present? && current_user.errors[:user_messages].present?
            redish_error! :conflict, *current_user.errors[:user_messages]
          end
        when :password
          current_user.update_with_password(
            password: params[:password],
            password_confirmation: params[:password_confirmation],
            current_password: params[:current_password],
          )
        else
          redish_error! :bad_request
        end

        if current_user.errors.present?
          redish_error! :bad_request, *current_user.errors.full_messages
        end

        present current_user.decorate, with: Entities::User
      end
    end
  end
end
