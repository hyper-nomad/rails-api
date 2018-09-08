class CreateAdminRoles < ActiveRecord::Migration
  def change
    create_table :admin_roles do |t|
      t.string :key
      t.string :name

      t.timestamps null: false
    end
  end
end
