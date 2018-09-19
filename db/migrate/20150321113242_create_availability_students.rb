class CreateAvailabilityStudents < ActiveRecord::Migration
  def change
    create_table :availability_students do |t|
      t.integer :user_id
      t.integer :availability_id
      t.datetime :read_at

      t.timestamps null: false
    end
  end
end
