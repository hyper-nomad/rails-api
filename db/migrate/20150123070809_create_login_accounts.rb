class CreateLoginAccounts < ActiveRecord::Migration
  def change
    create_table :login_accounts do |t|
      t.integer :user_id
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :access_token
      t.string :access_secret
      t.string :name
      t.string :nickname
      t.string :email
      t.string :image_url
      t.string :description
      t.text :credentials
      t.text :raw_info

      t.timestamps null: false
    end
    add_index :login_accounts, :user_id
    add_index :login_accounts, [:provider, :uid], unique: true
  end
end
