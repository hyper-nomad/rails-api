[
  {key: 'system_admin', name: 'システム管理者'},
  {key: 'sales_admin', name: '営業（管理者）'},
  {key: 'sales', name: '営業'},
  {key: 'supprot_admin', name: 'サポート（管理者）'},
  {key: 'supprot', name: 'サポート'},
#  {key: 'merchant_user', name: '店舗担当者様'},
].each{|role_set|
  role = AdminRole.find_or_create_by(key: role_set[:key])
  role.update(name: role_set[:name])
}
