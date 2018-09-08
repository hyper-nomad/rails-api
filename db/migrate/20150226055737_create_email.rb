class CreateEmail < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :naked, null: false

      t.timestamps null: false
    end
    add_index :emails, :naked, unique: true
  end
end
