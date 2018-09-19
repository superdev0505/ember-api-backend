class CreateAvailabilityMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :availability_messages do |t|
      t.integer :user_id
      t.integer :availability_id
      t.text :body

      t.timestamps
    end
  end
end
