class MerchantRoleAssign < ActiveRecord::Base
  belongs_to :merchant_user, class_name: 'MerchantUser', foreign_key: :merchant_user_id
  belongs_to :role, class_name: 'MerchantRole', foreign_key: :merchant_role_id
end
