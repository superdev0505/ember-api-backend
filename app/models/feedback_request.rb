class FeedbackRequest < ApplicationRecord

  validates_presence_of :user_id

  belongs_to :user # Student requesting feedback
  belongs_to :target, :class_name => "User" # Teacher giving feedback
  belongs_to :feedback
  belongs_to :availability


  before_create :generate_token
  before_create :find_target

  has_many :object_activities, :as => :target

  visitable class_name: "Visit"

  # after_create :alert_recipient

  after_create :notify!
  def notify!

    Alert.alert!(target, self, "create")

    # alert = Alert.create!(
    #   user: target,
    #   target: self,
    #   text: "#{self.user.first_name} requested feedback",
    #   read_link: "/feedback-requests/show/#{token}"
    # )

    # # Create notifications for the sender and receiver -> will appear in timeline
    # Notification.create!(
    #   user_id: user.id, target: self,
    #   notify: false,
    #   unread: false
    # )
    # Notification.create!(
    #   user_id: target.id, target: self,
    #   notify: true,
    #   unread: true
    # )
  end

  # Update notifications updated_at value on change
  # If the feedback is completed, delete the notification about the request
  has_many :notifications, as: :target
  def update_notifications
    if !feedback_id.blank?
      notifications.each do |a|
        ObjectActivity.faye_broadcast(a.user, a, true)
        a.destroy
      end
    elsif changed?
      notifications.each{|a| a.update_attribute(:target_updated_at, updated_at)}
    end
  end
  after_save :update_notifications


  protected

  # Create a unique random token - a link based on this is emailed to a student to complete
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless FeedbackRequest.exists?(token: random_token)
    end
  end


  # Find if a user has an account with the target email address
  def find_target
    target = User.where(:email => email).first
    self.target_id = target.id if target
  end


  # # Alert the recipient of the request
#   def alert_recipient
#     if target
#       # Create a Message object alerting them to the request
#       convo = Conversation.where(:active_users_cache => [user_id, target_id].sort.join(",")).first
#       if convo.nil?
#         convo = Conversation.create!
#         convo.conversation_members.create(:user_id => user_id)
#         convo.conversation_members.create(:user_id => target_id)
#         convo.reload
#       end
#       body = "<a href='/feedbacks/new/#{token}'>"
#       body += "New feedback request from #{user.name}"
#       body += "</a>"
#       convo.messages.create!(:body => body, :user_id => user.id)
#     elsif email # TODO
#
#     end
#   end

end
