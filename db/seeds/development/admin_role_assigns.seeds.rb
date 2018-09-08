after 'development:admin_users', 'admin_roles' do
  AdminRoleAssign.delete_all

  [
    {email: 'system_admin@l.gmo-k.jp', role: 'システム管理者'},
    {email: 'sales_admin@l.gmo-k.jp', role: '営業（管理者）'},
    {email: 'support_admin@l.gmo-k.jp', role: 'サポート（管理者）'},
  ].each{|user_role|
    admin = AdminUser.find_by_email user_role[:email]
    role = AdminRole.find_by_name user_role[:role]
    AdminRoleAssign.create admin: admin, role: role
  }
end
