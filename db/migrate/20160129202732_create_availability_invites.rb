class CreateAvailabilityInvites < ActiveRecord::Migration
  def change
    create_table :availability_invites do |t|
      t.string :availability_id, :user_id, :student_id
      t.boolean :responded, default: false
      t.boolean :accepted, default: false
      t.timestamps null: false
    end
  end
end
