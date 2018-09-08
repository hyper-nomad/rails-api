Doorkeeper::Application.delete_all

callback = "https://app.test.example.com/"
[
  {name: 'iOS app on test', uid: 'ios_app_id_on_test', secret: 'ios_app_secret_on_test', device_type: :IOsDevice, latest: '0.0.1'},
  {name: 'Android app on test', uid: 'android_app_id_on_test', secret: 'android_app_secret_on_test', device_type: :AndroidDevice, latest: '0.0.1'},
  {name: 'System Admin app on test', uid: 'system_admin_app_id_on_test', secret: 'system_admin_app_id_on_test', device_type: :SystemAdminDevice, latest: '0.0.1'},
  {name: 'Merchant Admin app on test', uid: 'merchant_admin_app_id_on_test', secret: 'merchant_admin_app_id_on_test', device_type: :MerchantAdminDevice, latest: '0.0.1'},
].each{|_app|
  app = Doorkeeper::Application.new(name: _app[:name], redirect_uri: callback)
  app.save!

  app.update(_app.slice(:uid, :secret, :device_type, :latest))
}
