class AddNotificationPreferenceFields < ActiveRecord::Migration[5.0]
  def change
    add_column :notification_preferences, :push_availability_accept_invite, :boolean, default: true
    add_column :notification_preferences, :email_availability_accept_invite, :boolean, default: false
    add_column :notification_preferences, :push_availability_reject_invite, :boolean, default: true
    add_column :notification_preferences, :email_availability_reject_invite, :boolean, default: false
  end
end
