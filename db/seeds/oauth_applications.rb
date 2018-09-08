callback = 'https://sl.kumapon.jp/'
%w(iOS Android).each{|app|
  exist = Doorkeeper::Application.where name: app
  Doorkeeper::Application.create name: app, redirect_uri: callback, latest: '1.0.0' unless exist
}
