class CreateAppDevices < ActiveRecord::Migration
  def change
    create_table :app_devices do |t|
      t.string :type
      t.references :user, index: true
      t.string :token
      t.datetime :revoked_at

      t.timestamps null: false
    end

    add_index :app_devices, [:type, :token], unique: true, name: 'unique_device_token'
  end
end
