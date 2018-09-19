class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.string :name
      t.text :active_users_cache
      t.integer :messages_count, default: 0
      t.integer :availability_id
      t.timestamps null: false
    end
  end
end
