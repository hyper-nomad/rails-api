class User < ActiveRecord::Base

  has_many :login_accounts, dependent: :destroy
  has_many :devices, class_name: 'AppDevice'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :confirmable, :lockable, :omniauthable

  def registration_status
    return :canceled if deleted_at?
    return :registered if has_oauth_account?
    return :unconfirmed unless confirmed?
    return :required_info if encrypted_password.blank?
    :registered
  end

  def has_oauth_account?
    login_accounts.count >= 1
  end

  %i(canceled unconfirmed required_info registered).each do |_status|
    define_method(:"#{_status}?") { registration_status == _status}
  end
end
