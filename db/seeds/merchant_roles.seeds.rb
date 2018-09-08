[
  {key: 'owner', name: 'オーナー・店長（管理者）'},
  {key: 'staff', name: 'ホールスタッフ'}
].each{|role_set|
  role = MerchantRole.find_or_create_by(key: role_set[:key])
  role.update(name: role_set[:name])
}
