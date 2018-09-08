class SystemAdminDevice < AppDevice
  def self.find_user id
    MerchantUser.find(id)
  end
end
