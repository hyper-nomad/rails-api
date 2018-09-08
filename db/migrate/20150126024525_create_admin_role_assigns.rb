class CreateAdminRoleAssigns < ActiveRecord::Migration
  def change
    create_table :admin_role_assigns do |t|
      t.integer :admin_role_id
      t.integer :admin_user_id

      t.timestamps null: false
    end
    add_index :admin_role_assigns, :admin_user_id
    add_index :admin_role_assigns, [:admin_role_id, :admin_user_id], unique: true
  end
end
