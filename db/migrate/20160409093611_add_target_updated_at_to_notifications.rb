class AddTargetUpdatedAtToNotifications < ActiveRecord::Migration
  def up
    add_column :notifications, :target_updated_at, :datetime

    Notification.all.each do |n|
      n.update_attribute :target_updated_at, n.target.updated_at
    end
  end

  def down
    remove_column :notifications, :target_updated_at
  end
end
