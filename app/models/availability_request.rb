class AvailabilityRequest < ApplicationRecord

  belongs_to :user
  belongs_to :location

  has_many :object_activities, as: :target
  has_many :comments, as: :target

  has_many :availabilities

  has_many :availability_request_votes

  default_scope { order(created_at: :desc) }

  def watching_users
    users = User.joins(:locations).where(:locations => {:id => location_id})
    # TODO: add experience filters
    # watching_users = watching_users.joins(:job_title).where(:job_title => [""])

    users
  end

  # On any change, make sure interested users see updates
  def websocket_update
    json = self.to_jsonapi
    watching_users.each do |user|
      UpdatesChannel.broadcast_to(user, {loadModels: [json]})
    end
  end
  after_save :websocket_update

  # after_create :notify!
  # # Create Notification objects for the creating user and all users matching the Location and Experience criteria
  # def notify!
  #
  #   users = (watching_users + [user]).uniq
  #
  #   users.each do |target_user|
  #
  #     if target_user == user
  #       Notification.create!(
  #         user: target_user,
  #         target: self,
  #         notify: true,
  #         unread: false
  #       )
  #     else
  #       Notification.create!(
  #         user: target_user,
  #         target: self,
  #         notify: false,
  #         unread: true
  #       )
  #     end
  #   end
  #
  # end

  # When created, the creator should automatically vote for it
  after_create :create_vote
  def create_vote
    AvailabilityRequestVote.create!(
      availability_request: self,
      user: user
    )
  end


  # has_many :notifications, as: :target
  # # When changed, update the updated_at attribute of any notifications
  # def update_notifications
  #   if changed?
  #     notifications.each{|a| a.update_attribute(:target_updated_at, updated_at)}
  #     # Update watching users
  #     watching_users.each do |user|
  #       join = Notification.where(target: self, user: user).first
  #       if join.nil?
  #         Notification.create!(user: user, target: self, notify: true, unread: true)
  #       end
  #     end
  #   end
  # end
  # after_save :update_notifications

end
