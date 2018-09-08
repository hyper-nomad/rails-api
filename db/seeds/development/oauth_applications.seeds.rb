callback = "http://localhost:3000"
[
  {name: 'iOS app on development', uid: 'ios_app_id_on_development', secret: 'ios_app_secret_on_development', device_type: :IOsDevice, latest: '0.1.0'},
  {name: 'Android app on development', uid: 'android_app_id_on_development', secret: 'android_app_secret_on_development', device_type: :AndroidDevice, latest: '0.1.0'},
  {name: 'System Admin app on development', uid: 'system_admin_app_id_on_development', secret: 'system_admin_app_id_on_development', device_type: :SystemAdminDevice, latest: '0.1.0'},
  {name: 'Merchant Admin app on development', uid: 'merchant_admin_app_id_on_development', secret: 'merchant_admin_app_id_on_development', device_type: :MerchantAdminDevice, latest: '0.1.0'},
].each{|_app|
  app = Doorkeeper::Application.find_or_initialize_by(name: _app[:name])
  app.redirect_uri = callback
  app.save!

  app.update(_app.slice(:uid, :secret, :device_type, :latest))
}
