[
  {email: 'system_admin@l.gmo-k.jp', password: 'hoge1234'},
  {email: 'sales_admin@l.gmo-k.jp', password: 'hoge1234'},
  {email: 'support_admin@l.gmo-k.jp', password: 'hoge1234'},
].each{|account|
  admin = AdminUser.find_or_create_by email: account[:email]
  admin.password = account[:password]
  admin.password_confirmation = account[:password]
  admin.save
}
