class CreateAvailabilityRequestVotes < ActiveRecord::Migration[5.0]
  def change
    return false if ActiveRecord::Base.connection.table_exists? 'availability_request_votes'
    create_table :availability_request_votes do |t|
      t.integer :user_id
      t.integer :availability_request_id

      t.timestamps null: false
    end
  end
end
