class AddUserIdToNotificationPreferences < ActiveRecord::Migration[5.0]
  def up
    add_column :notification_preferences, :user_id, :integer

    NotificationPreference.all.each do |pref|
      user = User.where(:notification_preference_id => pref.id).first
      pref.update_attribute(:user_id, user.id) if user
    end
  end

  def down
    remove_column :notification_preferences, :user_id
  end
end
