class SignedUser < User
  class PersistedError < StandardError; end
  class InvalidLoginInfo < StandardError; end

  devise :validatable

  validate :uniqueness_of_naked_email
  after_save :save_naked_email, on: [:create, :update]

  # override Devise::Models::Validatable#password_required?
  def password_required?
    !password.nil? || !password_confirmation.nil?
  end

  # override Devise::Models::Confirmable#send_on_create_confirmation_instructions
  def send_on_create_confirmation_instructions
    generate_confirmation_token!  unless @raw_confirmation_token
    send_devise_notification(:confirmation_on_create_instructions, @raw_confirmation_token, {})
  end

  def self.ipass_authenticate email, password
    user = find_for_authentication(:email => email)
    user && user.valid_password?(password) ? user : nil
  end

  def uniqueness_of_naked_email
    return unless email_changed?
    if Email.include?(naked_email)
      errors[:user_messages] = :'error.sign_up.naked_email_duplicated'
    end
  end

  def save_naked_email
    Email.create_naked!(naked_email) if email_changed?
  end

  def naked_email
    NakedEmail.new(self.email)
  end
end
