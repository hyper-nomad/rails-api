module Doorkeeper
  class Application
    # NOTE: 順番を変えない。追加分は末尾。
    enum device_type: %i(
      AppDevice
      IOsDevice
      AndroidDevice
      SystemAdminDevice
      MerchantAdminDevice
    )

    def device
      self.device_type.constantize
    end
  end
end
