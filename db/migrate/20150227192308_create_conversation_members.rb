class CreateConversationMembers < ActiveRecord::Migration
  def change
    create_table :conversation_members do |t|
      t.integer :conversation_id
      t.integer :user_id
      t.boolean :active, default: true
      t.datetime :time_left, :last_read

      t.timestamps null: false
    end
  end
end
