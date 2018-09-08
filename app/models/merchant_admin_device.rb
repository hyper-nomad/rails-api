class MerchantAdminDevice < AppDevice
  def self.find_user id
    MerchantUser.find(id)
  end
end
