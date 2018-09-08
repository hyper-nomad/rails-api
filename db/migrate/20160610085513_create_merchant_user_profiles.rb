class CreateMerchantUserProfiles < ActiveRecord::Migration
  def change
    create_table :merchant_user_profiles do |t|
      t.integer :merchant_user_id, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :first_name_kana
      t.string :last_name_kana
      t.integer :gender
      t.date :birthday
      t.integer :prefecture
      t.string :address
      t.integer :job_category
      t.integer :years_experience
      t.string :qualification
      t.integer :service_type
      t.string :message
      t.string :icon_url

      t.timestamps null: false
    end

    add_index :merchant_user_profiles, :merchant_user_id, unique: true
    add_index :merchant_user_profiles, [:last_name, :first_name]
  end
end
