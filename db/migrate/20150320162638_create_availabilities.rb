class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :user_id
      t.integer :max_students
      t.text :info
      t.integer :target_experience_min
      t.integer :target_experience_max
      t.integer :location_id
      t.boolean :cancelled, default: false
      t.datetime :cancelled_at
      
      t.datetime :read_at # For notifications to the creating user

      t.timestamps null: false
    end
  end
end
