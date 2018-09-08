class CreateMerchantRoles < ActiveRecord::Migration
  def change
    create_table :merchant_roles do |t|
      t.string :key
      t.string :name

      t.timestamps null: false
    end
  end
end
