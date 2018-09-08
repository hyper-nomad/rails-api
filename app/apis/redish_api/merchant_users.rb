module RedishAPI
  class MerchantUsers < Grape::API
    # TODO: 全アクションで AppDevice が MerchantAdminDevice であることを強制する
    namespace :merchant do
      resource :users do
        desc "Show own user",
          headers: Document.request_headers(REDISH_ACCESS_TOKEN_KEY),
          detail: I18n.t(:show, scope: [:api, :doc, :merchant_users],
                        redish_access_token: Document.redish_access_token),
          entity: Grape::Entity,
          http_codes: [
            *I18n.t([:ok, :unauthorized], scope: :sc),
          ]
        get '/me' do
          redish_error! :unauthorized unless current_merchant_user
          present current_merchant_user, with: Entities::MerchantUser
        end

        desc "Sign up user",
          headers: Document.request_headers(REDISH_APP_ID),
          detail: I18n.t(:sign_up, scope: [:api, :doc, :merchant_users]),
          entity: Grape::Entity,
          http_codes: [ *I18n.t([:created, :invalid_parameter, :unauthorized, :conflict], scope: :sc),
          ]
        params do
          requires :email, type: String, desc: 'Email Address'
          requires :password, type: String, desc: 'Password'
          requires :password_confirmation, type: String, desc: 'Password Confirmation'
          requires :role, type: Symbol, values: [:owner, :staff], desc: 'Merchant Admin Role'
        end
        post '/' do
          redish_error! :unauthorized unless merchant_redish_app

          begin
            user = UserAuth.new(login_key).sign_up_merchant_user(params)
          rescue MerchantUser::PersistedError
            redish_error! :conflict
          rescue MerchantUser::UnknownRoleError
            redish_error! :invalid_parameter
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
          detail: I18n.t(:edit, scope: [:api, :doc, :merchant_users]),
          entity: Grape::Entity,
          http_codes: [
            *I18n.t([:ok, :invalid_parameter, :unauthorized], scope: :sc),
          ]
        params do
          optional :email,                 type: String, desc: 'New Email Address'
          optional :password,              type: String, desc: 'New Password'
          optional :password_confirmation, type: String, desc: 'New Password Confirmation'
          optional :current_password,      type: String, desc: 'Current Password'
          optional :role,                  type: Symbol, values: [:owner, :staff], desc: 'Merchant Admin Role'
          exactly_one_of :email, :password, :role
          all_or_none_of :password, :password_confirmation, :current_password
        end
        put '/' do
          authenticate_merchant!

          # TODO: moduleを一枚挟む実装にしたい
          case key_from_params %w(email password role)
          when :email
            if current_merchant_user.naked_email == NakedEmail.new(params[:email])
              redish_error! :bad_request, :'error.email.same_email'
            end
            current_merchant_user.email = params[:email]
            current_merchant_user.save

            if current_merchant_user.errors.present? && current_merchant_user.errors[:user_messages].present?
              redish_error! :conflict, *current_merchant_user.errors[:user_messages]
            end
          when :password
            current_merchant_user.update_with_password(
              password: params[:password],
              password_confirmation: params[:password_confirmation],
              current_password: params[:current_password],
            )
          when :role
            authorize! :update_role, current_merchant_user
            MerchantRole.transaction do
              # TODO: 本来は user has many roles であるが簡単のため1:1にしている
              current_merchant_user.role_assigns.delete_all
              role = MerchantRole.find_by_key(params[:role])
              current_merchant_user.role_assigns.create(merchant_role_id: role.id)
            end
          else
            redish_error! :bad_request
          end

          if current_merchant_user.errors.present?
            redish_error! :bad_request, *current_merchant_user.errors.full_messages
          end

          present current_merchant_user.reload, with: Entities::MerchantUser
        end
      end
    end
  end
end
