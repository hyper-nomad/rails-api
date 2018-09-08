module RedishAPI
  class AppDevices < Grape::API
    resource :app_devices do
      desc "Register device token",
           headers: {
             REDISH_APP_ID => {
               description: 'Redish application token for api auth',
               required: true
             },
             REDISH_ACCESS_TOKEN_KEY => {
               description: 'Redish Access Token',
               required: false, #指定無しもあり
             },
           },
           entity: Grape::Entity,
           http_codes: I18n.t([:created, :unauthorized, :invalid_parameter], scope: [:sc])
      params do
        requires :token, type: String, desc: 'Device token'
        requires :app_version, type: String, desc: 'app version'
      end
      post '/' do
        app = Doorkeeper::Application.find_by_uid headers[REDISH_APP_ID]
        redish_error! :unauthorized unless app

        authenticate! if headers.keys.include?(REDISH_ACCESS_TOKEN_KEY)

        device = app.device.find_or_create_by(token: params[:token])
        device.user = current_user unless device.user
        device.version = params[:app_version]
        device.revoked_at = nil

        device.changed? ? device.save : device.touch
        {}
      end

      desc 'Show newest version',
           headers: {
             REDISH_APP_ID => {
               description: 'Redish application token for api auth',
               required: true
             }
           },
           entity: Grape::Entity
      get '/latest' do
        app = Doorkeeper::Application.find_by_uid headers[REDISH_APP_ID]
        redish_error! :unauthorized unless app

        app.attributes.slice(*%w(name uid latest))
      end
    end
  end
end
