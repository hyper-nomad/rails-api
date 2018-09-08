class UserAuth
  class NotRegisteredUserError < StandardError; end
  class UnauthorizedError < StandardError; end
  class ProviderError < StandardError; end

  def initialize key
    provider = {
      email: AuthProvider::IPass,
      facebook_access_token: AuthProvider::FacebookOAuth,
    }[key]

    raise(ArgumentError.new("unkown key")) unless provider

    self.extend provider
  end
end
