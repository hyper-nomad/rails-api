module AuthProvider
  class NotFetchAccountOnExternalService < StandardError; end

  module IPass

    def get_login credentials
      user = SignedUser.ipass_authenticate credentials[:email], credentials[:password]
      raise SignedUser::InvalidLoginInfo unless user
      user
    end

    def sign_up_user credentials
      if User.where(email: credentials[:email]).exists?
        raise SignedUser::PersistedError
      end
      user = SignedUser.new(email: credentials[:email],
                            password: credentials[:password],
                            password_confirmation: credentials[:password_confirmation])
      user.skip_confirmation!
      user
    end

    def sign_up_merchant_user credentials
      if MerchantUser.where(email: credentials[:email]).exists?
        raise MerchantUser::PersistedError
      end
      user = MerchantUser.new(email: credentials[:email],
                            password: credentials[:password],
                            password_confirmation: credentials[:password_confirmation])
      user.skip_confirmation!
      role = MerchantRole.find_by_key(credentials[:role])
      unless role
        raise MerchantUser::UnknownRoleError
      end
      user.role_assigns.new(merchant_role_id: role.id)
      user
    end
  end

  module ServiceOAuth
    def get_login _credentials
      set_credentials _credentials

      account = login_account
      raise NotFetchAccountOnExternalService unless account
      account.refresh!

      user = account.user
      raise UnsignedUser::Unregistered unless user
      user
    end

    def sign_up_user _credentials
      set_credentials _credentials

      user = UnsignedUser.new
      _account = login_account
      raise NotFetchAccountOnExternalService unless _account
      raise UnsignedUser::LoginAccountPersistedError if _account.persisted?
      user.login_accounts << _account
      user
    end

    private

    def login_account
      return nil unless me

      account = LoginAccount.where(provider: provider, uid: uid).first_or_initialize
      account.set_account_info account_info
      account
    end
  end

  module FacebookOAuth
    extend Memoist
    include ServiceOAuth

    attr_accessor :access_token

    private
    def provider; :facebook; end

    def client
      Koala::Facebook::API.new access_token
    end

    def me
      client.get_object('me', {fields: [:id, :name, :email, :picture]})
    rescue Koala::Facebook::AuthenticationError
      nil
    end
    memoize :me

    def uid
      me['id']
    end

    def image_url
      me['picture']['data']['url'] rescue nil
    end

    def account_info
      {
        'provider' => provider,
        'uid'      => uid,
        'info'     => {
          'email' => me['email'],
          'name'  => me['name'],
          'image' => image_url
        },
        'credentials' => {
          'token' => access_token
        },
        'extra' => {}
      }
    end

    def set_credentials _credentials
      self.access_token = _credentials[:facebook_access_token]
    end
  end
end

