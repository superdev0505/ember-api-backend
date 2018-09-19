class CreateGroupMembers < ActiveRecord::Migration
  def change
    create_table :group_members do |t|
      t.integer :group_id, :user_id
      t.timestamps null: false
    end
  end
end
