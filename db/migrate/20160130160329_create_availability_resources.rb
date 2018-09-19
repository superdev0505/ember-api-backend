class CreateAvailabilityResources < ActiveRecord::Migration
  def change
    create_table :availability_resources do |t|
      t.integer :availability_id, :resource_id, :user_id
      t.string :name, :resource_type
      t.text :notes
      t.timestamps null: false
    end
  end
end
