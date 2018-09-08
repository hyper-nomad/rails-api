module RedishAPI
  class MerchantUserProfiles < Grape::API
    namespace :merchant do
      resource :merchant_users do
        desc "Create user profile",
          headers: Document.request_headers(REDISH_ACCESS_TOKEN_KEY),
          detail: I18n.t(:create, scope: [:api, :doc, :merchant, :merchant_users],
                        redish_access_token: Document.redish_access_token),
          entity: Grape::Entity,
          http_codes: [ *I18n.t([:created, :invalid_parameter, :unauthorized, :conflict], scope: :sc),
          ]
        params do
          requires :merchant_user_id, type: Integer, desc: 'Merchant User Id'
          requires :first_name, type: String, desc: 'First Name'
          requires :last_name, type: String, desc: 'Last Name'
          optional :first_name_kana, type: String, desc: 'First Name Kana'
          optional :last_name_kana, type: String, desc: 'Last Name Kana'
          optional :gender, type: Integer, desc: 'Gender'
          optional :birthday, type: Date, desc: 'Birthday'
          optional :prefecture, type: Integer, desc: 'Prefecture'
          optional :address, type: String, desc: 'Address'
          optional :years_experience, type: Integer, desc: 'Years Experience'
          optional :address, type: String, desc: 'Address'
          optional :service_type, type: Integer, desc: 'Service Type'
          optional :message, type: String, desc: 'Message'
          optional :icon_url, type: String, desc: 'Icon Url'
        end
        post ':id/profile' do
          redish_error! :unauthorized unless current_merchant_user
          begin
            merchant_user_profile = MerchantUserProfile.new.set_profile params
          rescue MerchantUserProfile::PersistedError
            redish_error! :conflict
          end

          begin
            merchant_user_profile.save!
          rescue ActiveRecord::RecordInvalid => e
            redish_error! :invalid_parameter, *e.record.errors.full_messages
          end
          present merchant_user_profile, with: Entities::MerchantUserProfile
        end
      end
    end
  end
end
