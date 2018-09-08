class MerchantRole < ActiveRecord::Base
  has_many :merchant_role_assigns
  has_many :merchant_users, :through => :merchant_role_assigns
end
