class CreateUserSpecialties < ActiveRecord::Migration
  def change
    create_table :user_specialties do |t|
      t.integer :user_id
      t.integer :specialty_id
      t.text :description
      t.integer :experience

      t.timestamps null: false
    end
  end
end
