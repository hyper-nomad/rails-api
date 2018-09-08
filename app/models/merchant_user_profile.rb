class MerchantUserProfile < ActiveRecord::Base
  class PersistedError < StandardError; end

  belongs_to :merchant_user, class_name: 'MerchantUser', foreign_key: :merchant_user_id

  validates :merchant_user_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :first_name_kana, format: { with: /\A[\p{hiragana}ー－]+\Z/, message: 'はひらがなで入力して下さい。' }
  validates :last_name_kana, format: { with: /\A[\p{hiragana}ー－]+\Z/, message: 'はひらがなで入力して下さい。' }

  def set_profile param
    if MerchantUserProfile.where(merchant_user_id: param[:merchant_user_id]).exists?
      raise MerchantUserProfile::PersistedError
    end
    self.merchant_user_id = param[:merchant_user_id]
    self.first_name = param[:first_name]
    self.last_name = param[:last_name]
    self.first_name_kana = param[:first_name_kana]
    self.last_name_kana = param[:last_name_kana]
    self.gender = param[:gender]
    self.birthday = param[:birthday]
    self.prefecture = param[:prefecture]
    self.address = param[:address]
    self.years_experience = param[:years_experience]
    self.qualification = param[:qualification]
    self.service_type = param[:service_type]
    self.message = param[:message]
    self.icon_url = param[:icon_url]
    return self
  end
end
