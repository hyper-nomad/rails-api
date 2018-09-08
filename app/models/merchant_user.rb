class MerchantUser < ActiveRecord::Base
  class PersistedError < StandardError; end
  class UnknownRoleError < StandardError; end

  has_many :devices, class_name: 'AppDevice'
  has_many :role_assigns, class_name: 'MerchantRoleAssign'
  has_many :roles, class_name: 'MerchantRole', through: :role_assigns

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :confirmable, :lockable

  # override Devise::Models::Validatable#password_required?
  def password_required?
    !password.nil? || !password_confirmation.nil?
  end

  def registration_status
    return :canceled if deleted_at?
    return :unconfirmed unless confirmed?
    return :required_info if encrypted_password.blank?
    :registered
  end

  %i(canceled unconfirmed required_info registered).each do |_status|
    define_method(:"#{_status}?") { registration_status == _status}
  end

  def role
    roles.first.try!(:key)
  end
end
