class CreateUserInterests < ActiveRecord::Migration
  def change
    create_table :user_interests do |t|
      t.integer :user_id
      t.integer :specialty_id

      t.timestamps null: false
    end
    
    add_column :users, :user_interests_count, :integer, :default => 0
  end
end
