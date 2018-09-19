class CreateNotificationPreferences < ActiveRecord::Migration
  def up
    # Notification Preference object - has boolean fields for whether to send push notifications and/or emails for all possible alerts
    # Name these fields after how they are stored in object_activity
    # See key in ObjectActivity model file.

    fields = [:conversation_create, :availability_create, :availability_invite,
      :feedbackrequest_create, :feedback_create, :availability_sign_up, :availability_cancel,
      :availability_create_resource, :availability_update, :availability_destroy]

    create_table :notification_preferences do |t|
      # t.integer :user_id, null: false
      fields.each do |f|
        # By default send both push notifications and emails for everything except messages (these will get annoying in a back-and-forth convo!)
        t.boolean "push_#{f}".to_sym, default: true
        t.boolean "email_#{f}".to_sym, default: [:conversation_create].include?(f) ? false : true
      end

      t.timestamps null: false
    end

    # add_index :notification_preferences, :user_id, unique: true

    add_column :users, :notification_preference_id, :integer

    User.all.each do |a|
      n = NotificationPreference.create!#(user_id: a.id)
      a.update_attribute(:notification_preference_id, n.id)
    end
  end

  def down
    drop_table :notification_preferences
    remove_column :users, :notification_preference_id
  end
end
