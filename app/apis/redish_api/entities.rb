module RedishAPI
  module Entities
    class User < Grape::Entity
      expose :email
      expose :registration_status
    end
    class MerchantUser < Grape::Entity
      expose :email
      expose :registration_status
      expose :role
    end
    class MerchantUserProfile < Grape::Entity
      expose :merchant_user_id
      expose :first_name
      expose :last_name
      expose :first_name_kana
      expose :last_name_kana
      expose :gender
      expose :birthday
      expose :prefecture
      expose :address
      expose :job_category
      expose :years_experience
      expose :qualification
      expose :service_type
      expose :message
      expose :icon_url
    end
  end
end
