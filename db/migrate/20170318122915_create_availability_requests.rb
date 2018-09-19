class CreateAvailabilityRequests < ActiveRecord::Migration[5.0]
  def change
    return false if ActiveRecord::Base.connection.table_exists? 'availability_requests'
    create_table :availability_requests do |t|
      t.integer :user_id
      t.integer :location_id
      t.text :info
      t.integer :target_experience_min
      t.integer :target_experience_max
      t.integer :availability_request_votes_count

      t.timestamps null: false
    end

    # Track when an availability is made in response to a request
    add_column :availabilities, :availability_request_id, :integer

    # Add notification preferences
    add_column :notification_preferences, :push_availabilityrequest_create, :boolean, default: true
    add_column :notification_preferences, :email_availabilityrequest_create, :boolean, default: false
  end
end
