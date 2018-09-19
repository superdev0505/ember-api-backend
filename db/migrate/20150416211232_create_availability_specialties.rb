class CreateAvailabilitySpecialties < ActiveRecord::Migration
  def change
    create_table :availability_specialties do |t|
      t.integer :availability_id
      t.integer :specialty_id

      t.timestamps null: false
    end
  end
end
