class CreateAlerts < ActiveRecord::Migration[5.0]
  def change
    create_table :alerts do |t|
      t.integer :user_id
      t.integer :target_id
      t.string :target_type
      t.text :text
      t.boolean :unread, default: true
      t.string :read_link

      t.timestamps
    end
  end
end
