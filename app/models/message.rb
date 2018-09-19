class Message < ApplicationRecord

#  belongs_to :author, :class_name => "User"
  belongs_to :user
  belongs_to :conversation, counter_cache: true
  belongs_to :availability

  default_scope { order(created_at: :desc) }


  # For messages of an availability, create a conversation to tag them with
  def match_availability_message_to_convo
    if conversation_id.nil? && !availability_id.nil?
      conversation = Conversation.where(availability_id: availability_id).first
      if conversation.nil?
        conversation = Conversation.create(availability_id: availability_id, name: "Teaching #{availability.start_time.strftime('%H:%M %d/%m/%Y')}")
        availability.availability_users.each do |join|
          conversation.conversation_members.create!(user: join.user, admin: join.admin)
        end
      end
      self.conversation = conversation
    end
  end
  before_create :match_availability_message_to_convo

  # To track conversation activity, update the conversation after save
  after_save :update_conversation#

  visitable class_name: "Visit"

  def update_conversation
    conversation.update_attribute(:updated_at, Time.now) if conversation
  end


  # Broadcast to any subscribed channels (subscribed to from conversations/show page)
  after_create :broadcast
  def broadcast
    json = user.alert_counts
    json[:loadModels] = [self.to_jsonapi]
    conversation.conversation_members.includes(:user).all.collect{|a| a.user}.each do |user|
      UpdatesChannel.broadcast_to(user, json)
    end
  end


  # Send notifications - create an Alert object and send to Pushbots
  after_create :notify!
  def notify!

    # Set the updated_at on the conversation
    update_conversation

    # Notify users
    users = conversation.active_users - [user]
    Alert.alert!(users, self, "create")

  end

end
