class AdminRole < ActiveRecord::Base
  has_many :admin_role_assigns
  has_many :admin_users, :through => :admin_role_assigns
end
