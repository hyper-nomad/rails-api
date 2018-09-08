module RedishOAuth
  module AccessToken
    def self.generate app, resource_user
      raise ArgumentError.new('invalid application') unless app && app.is_a?(Doorkeeper::Application)
      raise ArgumentError.new('invalid user') unless resource_user && [User, MerchantUser, AdminUser].any?{|clazz| resource_user.is_a?(clazz)}

      scope = []          # not controll by scope
      expire = nil        # no limit
      reset_token = false # not resetable

      Doorkeeper::AccessToken.find_or_create_for app, resource_user.id,
                                                 scope, expire, reset_token
    end

    def self.find token
      access_token = Doorkeeper::AccessToken.where(token: token).first
      raise UserAuth::UnauthorizedError unless access_token
      access_token
    end
  end

  def self.authenticated_user token
    access_token = Doorkeeper::AccessToken.where(revoked_at: nil,
                                                 token: token).first
    begin
      app = Doorkeeper::Application.find access_token.application_id
      app.device.find_user access_token.resource_owner_id
    rescue
      nil
    end
  end

  def self.authenticated_merchant_user token
    access_token = Doorkeeper::AccessToken.where(revoked_at: nil,
                                                 token: token).first
    return nil unless access_token

    app = access_token.application
    if app.device_type != 'MerchantAdminDevice'
      return nil
    end
    MerchantUser.find(access_token.resource_owner_id)
  end
end
