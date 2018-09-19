class Alert < ApplicationRecord

  belongs_to :user
  belongs_to :target, polymorphic: true

  default_scope { order(created_at: :desc) }

  # Create alert objects for a target and set of users
  # Do this as an asynchronous job
  def self.alert!(users, target, action, message=nil)
    CreateAlertsJob.perform_later(users: users, target: target, action: action, message: message)
  end

  # Update the app on save rather than on create
  # This will update when an alert is read
  after_save :broadcast
  def broadcast
    # Return up to date notification counts
    json = user.alert_counts
    json[:loadModels] = [self.to_jsonapi]
    UpdatesChannel.broadcast_to(user, json)
    #puts "BROADCASTING ALERT #{id} TO USER #{user.email}: #{json}"
  end
end
