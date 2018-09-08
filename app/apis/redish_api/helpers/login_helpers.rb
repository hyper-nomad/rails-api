module RedishAPI
  module Helpers
    module LoginHelpers
      def redish_access_token
        @redish_access_token ||= headers[REDISH_ACCESS_TOKEN_KEY]
      end

      def current_user
        @current_user ||= RedishOAuth.authenticated_user redish_access_token
      end

      def redish_app
        Doorkeeper::Application.find_by_uid headers[REDISH_APP_ID]
      end

      def login_key
        @login_key ||= key_from_params %w(email facebook_access_token)
      end

      def key_from_params _keys
        (_keys & params.keys).first.to_sym
      end

      def generate_token user
        token = RedishOAuth::AccessToken.generate redish_app, user
        @redish_access_token = token.token
      end

      def response_token user
        path = case
               when user.is_a?(User)
                 '/v1/users/me.json'
               when user.is_a?(MerchantUser)
                 '/v1/merchant/users/me.json'
               when user.is_a?(AdminUser)
                 '/v1/admin/users/me.json'
               end
        header 'Location', path
        {redish_access_token: generate_token(user)}
      end

      def authenticate! _method = :registered?
        redish_error! :unauthorized unless current_user
        redish_error! :conflict unless current_user.send(_method)
        true
      end

      def merchant_redish_app
        Doorkeeper::Application.where(uid: headers[REDISH_APP_ID],
                                      device_type: Doorkeeper::Application.device_types['MerchantAdminDevice']).first
      end

      def current_merchant_user
        @current_merchant_user ||= RedishOAuth.authenticated_merchant_user redish_access_token
      end

      def authenticate_merchant! _method = :registered?
        redish_error! :unauthorized unless current_merchant_user
        redish_error! :conflict unless current_merchant_user.send(_method)
        true
      end
    end
  end
end
