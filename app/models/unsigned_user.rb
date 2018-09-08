class UnsignedUser < User
  class LoginAccountPersistedError < StandardError; end
  class Unregistered < StandardError; end

  before_create :set_default_email

  def set_default_email
    if self.email.blank?
      skip_confirmation!
      self.email = login_accounts.first.try(:email)
    end
  end
end
