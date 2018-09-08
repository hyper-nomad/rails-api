class AdminUser < ActiveRecord::Base
  has_many :admin_role_assigns
  has_many :roles, :through => :admin_role_assigns

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
end
