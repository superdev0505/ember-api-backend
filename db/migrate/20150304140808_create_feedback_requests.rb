class CreateFeedbackRequests < ActiveRecord::Migration
  def change
    create_table :feedback_requests do |t|

      t.integer :user_id, :target_id, :feedback_id
      t.string :email, :token
      t.text :event_description, :event_reflection, :message
      t.datetime :event_time, :completed_at
      t.boolean :request_signoff
      t.timestamps null: false
    end
    
    add_index :feedback_requests, :token, unique: true

  end
end
