class Notification < ApplicationRecord


  # Required for truncate
  # (note extend rather than include as it's used in a class method)
  extend ActionView::Helpers::TextHelper # truncate

  belongs_to :user
  belongs_to :target, :polymorphic => true

  # Notifications are now dynamically generated - send a unique UID to stop them being downloaded twice
  # Generate from the unique parts of the notification object but not dynamic parts (updated_at, read_at)
  # Make a hash, square to remove negative numbers and convert to integer
  def uid
#    ustr = "u#{user_id}t#{target_type}#{target_id}c#{created_at.strftime('%d%m%y%H%M%S')}"
    # ustr.to_i(36)
#    ustr.hash.abs.to_i

    # Make a simple string of attributes concatenated together to act as an ID
    case target_type
    when "Conversation"
      ustr = "1"
    when "Feedback"
      ustr = "2"
    when "FeedbackRequest"
      ustr = "3"
    when "Availability"
      ustr = "4"
    else
      ustr = "5"
    end
    ustr = "#{ustr}#{user_id}#{target_id}#{created_at.strftime('%d%m%y%H%M%S')}"
    return ustr.to_i
  end


  # Given a notifiable object and a user, generate a dummy Notification object.
  # This will not be saved to the DB.
  # Add a flag to broadcast via a push server.

  def self.new_for(user, object, send_notification=false)

    opts = {
      user_id: user.id,
      target: object,
      created_at: object.created_at, updated_at: object.updated_at
    }

    case object.class.to_s
    when "ConversationMember"
      # For conversations, feed in the conversationMember object to check the read_at attribute


      short_body = truncate(object.conversation.messages.last.body)
      opts = opts.merge(
#        body: "Message from #{object.conversation.active_users.collect{|a| a.name unless a == user}.compact.join(', ')}"
body: "#{object.conversation.messages.last.user.name.split[0]}: #{short_body}"
      )
      opts[:target] = object.conversation
      # Mark as unread if the conversation has been updated more recently than the converation member
      if object.last_read.nil? || object.conversation.updated_at > object.last_read
        opts[:read_at] = nil
      else
        opts[:read_at] = object.last_read
      end

    when "Feedback"

      if object.user_id == user.id
        opts = opts.merge(
          body: "Feedback received from #{object.target.name}",
          read_at: object.read_at
        )
      else
        opts = opts.merge(
          body: "Feedback sent to #{object.target.name}",
          read_at: Time.now - 1.day
        )
      end

    when "FeedbackRequest"

      opts = opts.merge(
        read_at: object.completed_at
      )
      # Different messages for sent requests, received requests and completed requests
      body = "Feedback Request"
      if object.user_id == user.id # Target is the person requesting feedback
        body = "You requested feedback from #{object.target.name}"
        opts[:read_at] = Time.now - 1.day
      else
        body = "Feedback request from #{object.user.name}"
      end
      if object.completed_at
        body += " (completed)"
      end
      opts[:body] = body

    when "Availability"

      opts = opts.merge(
        body: object.user == user ? "You created a new teaching session" : "#{object.user.name} is available to teach"
      )
      # Mark as read if it's in the past
      if object.end_time < Time.now
        opts[:read_at] = Time.now - 1.day
      end

    end

    n = Notification.new(opts)

    if send_notification
      # TODO: broadcast notification
    end

    n
  end


  def before_destroy
    ObjectActivity.faye_broadcast(user, self, true)
  end


  # For the client, the updated_at attribute should be when the TARGET was updated
  # Cache when the target updates
  def set_target_updated_on_save
    self.target_updated_at = target.updated_at
  end
  before_create :set_target_updated_on_save


  # # Broadcast to Faye to load data into app
#   def self.send_faye(user, object)
#     begin
#
#       # Make a notification linked to the object - except for messages where we link to the conversation object
#       if object.class.to_s == "Message"
#         nobj = ConversationMember.where(:user_id => user.id, :conversation_id => object.conversation.id).first
#       else
#         nobj = object
#       end
#   #    nobj = object.class.to_s == "Message" ? object.conversation : object
#
#       n = Notification.new_for(user, nobj)
#       data = {:Notification => n}
#       data[:Notification][:id] = n.uid
#       # data[:Notification]["targetType"] = n.target_type
#       # data[:Notification]["targetId"] = n.target_id
#
#       data[:loadModels] = {}
#       data[:loadModels][object.class.to_s.to_sym] = object
#
#
#       # # Broadcast to Faye
#       # data = {
#       #   loadModels: {
#       #     notification: [id],
#       #     target_type.to_sym => [target_id]
#       #   }
#       # }
#       # if target_type == "Conversation"
#       #   data[:loadModels][:Message] = [target.messages.last.id]
#       # end
#       m = {
#         :channel => "/users/#{user.id}/updates",
#         :data => data,
#         :ext => {:auth_token => FAYE_TOKEN}
#       }
#       uri = URI.parse("http://localhost:9292/faye")
#       Net::HTTP.post_form(uri, :message => m.to_json)
#
#     rescue
#       puts "UNABLE TO SEND FAYE MESSAGE"
#     end
#
#   end
#
#
#   # Send messages via PushPlugin
#   # curl -X POST \
#   # -H "x-pushbots-appid: 54cc0a511d0ab13c0528b459d" \
#   # -H "x-pushbots-secret: 1444fe8be3324ff7128f25aa18cdee12" \
#   # -H "Content-Type: application/json" \
#   # -d '{ "platform" : Array ,  "msg" : String ,  "sound" : String ,  "badge" : String   "tags" : Array ,  "except_tags" : Array ,  "active" : Array ,  "except_active" : Array ,  "alias" : String ,  "except_alias" : String ,  "payload" : JSON , }' \
#   # https://api.pushbots.com/push/all/
#   def self.broadcast(user, message)
#     uri = URI.parse("http://api.pushbots.com/push/all")
#     http = Net::HTTP.new(uri.host)
#     request = Net::HTTP::Post.new(uri.request_uri)
#     request["x-pushbots-appid"] = "5526d36017795905498b4580"
#     request["x-pushbots-secret"] = "46ef6a7a6548800948b40f9846668519"
#     request["Content-Type"] = "application/json"
#     request.set_form_data({
#       "msg" => message,
#       "alias" => user.email,
# #      "badge" => "1",
# #      "sound" => "event",
#       "platform" => [0,1]
#
#       # Below options don't seem to work...
#       # "OpenURL" => "users",
# #      "payload" => {"OpenURL" => "http://google.com"}.to_json
#     })
#     response = http.request(request)
#   end



  # # DEPRECATED - no longer saved to DB
#   after_save :broadcast
#   def broadcast
#     begin
#       # Broadcast to Amazon SNS
#       sns = Aws::SNS::Client.new(region: 'eu-west-1')
#
#       # Create_topic finds or creates topic based on name
#       # User should be subscribed from client side
#       topic = sns.create_topic(name: "user_updates_#{user_id}")
#
#       sns.publish(topic_arn: topic.topic_arn, message: body, subject: "New Notification")
#
#     rescue
#       puts "Unable to connect to Amazon AWS"
#     end
#
#     # Broadcast to Faye
#     data = {
#       loadModels: {
#         notification: [id],
#         target_type.to_sym => [target_id]
#       }
#     }
#     if target_type == "Conversation"
#       data[:loadModels][:Message] = [target.messages.last.id]
#     end
#     m = {
#       :channel => "/users/#{user_id}/updates",
#       :data => data,
#       :ext => {:auth_token => FAYE_TOKEN}
#     }
#     uri = URI.parse("http://localhost:9292/faye")
#     Net::HTTP.post_form(uri, :message => m.to_json)
#   end

end
