class AddVersionToAppDevice < ActiveRecord::Migration
  def change
    add_column :app_devices, :version, :string
  end
end
