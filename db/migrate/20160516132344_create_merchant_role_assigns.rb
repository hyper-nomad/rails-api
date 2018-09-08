class CreateMerchantRoleAssigns < ActiveRecord::Migration
  def change
    create_table :merchant_role_assigns do |t|
      t.integer :merchant_role_id
      t.integer :merchant_user_id

      t.timestamps null: false
    end
    add_index :merchant_role_assigns, :merchant_user_id
    add_index :merchant_role_assigns, [:merchant_role_id, :merchant_user_id], unique: true, name: :by_merchant_role_id_and_merchant_user_id
  end
end
