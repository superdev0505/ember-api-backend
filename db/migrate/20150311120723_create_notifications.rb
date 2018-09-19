class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :target_id
      t.string :target_type
      t.boolean :unread, default: false
      t.boolean :notify, default: false

      t.timestamps null: false
    end
  end
end
