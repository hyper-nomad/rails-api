class AdminRoleAssign < ActiveRecord::Base
  belongs_to :admin, class_name: 'AdminUser', foreign_key: :admin_user_id
  belongs_to :role, class_name: 'AdminRole', foreign_key: :admin_role_id
end
