include CustomUrlSchemeHelper

module RedishAPI
  REDISH_ACCESS_TOKEN_KEY = "Redish-Access-Token"
  REDISH_APP_ID = "Redish-Application-Token"

  autoload :MessageHelpers, 'redish_api/helpers/message_helpers'
  autoload :LoginHelpers, 'redish_api/helpers/login_helpers'
  autoload :Document, 'redish_api/document'

  class Root < Grape::API
    version 'v1', using: :path
    format :json

    helpers RedishAPI::Helpers::MessageHelpers
    helpers RedishAPI::Helpers::LoginHelpers

    rescue_from CanCan::AccessDenied do |e|
      error! "Access denied on #{e.action} #{e.subject.class}", 403
    end

    mount RedishAPI::Users
    mount RedishAPI::MerchantUsers
    mount RedishAPI::MerchantUserProfiles
    mount RedishAPI::AppDevices
    mount RedishAPI::Sessions

    add_swagger_documentation(
      mount_path: 'doc',
      base_path: '/api',
      api_version: 'v1',
      hide_documentation_path: true,
      format: :json
    )
  end
end
