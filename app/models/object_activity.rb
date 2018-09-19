class ObjectActivity < ApplicationRecord

  belongs_to :target, :polymorphic => true

  # Touch the target object after creation, make sure it is ordered correctly in the activity feed
  after_create :update_target
  def update_target
    target.update_attribute(:updated_at, Time.now)
  end

#  after_create :notify!

  # Define a code based on the object and controller action.
  # This code is the same as the field names in NotificationPreference.
  # This corresponds to notification types, and fields in the NotificationPreference model as follows:
  # - I receive a message (Conversation Create)
  # - A teaching session is posted matching my location/interests (Availability Create)
  # - I am invited to a teaching session (Availability Invite)
  # - I receive a feedback request (FeedbackRequest Create)
  # - I receive feedback on my teaching (Feedback Create)
  # - For a session I have created:
  #     - Someone signs up (Availability sign_up)
  #     - Someone cancels Availability (Availability cancel)
  # - For a session I am signed up to:
  #     - Resources are posted (Availability create_resource)
  #     - Details are changed (Availability update)
  #     - Session is cancelled (Availability destroy)
  def notification_code
    "#{target_type}_#{action}".downcase
  end

  # Method called from controller
  # Indicates which users should receive notifications
  # ALL relevant users will get a faye request; those in the passed array will get a push notification and their notification will be marked as unread
  def notify!(users=nil)
    puts "NOTIFYING"

    # Find notifications with the same target
    notifications = Notification.where(target: target).includes(:user => :notification_preference)
    notifications.each do |notification|

      # Where to redirect the user to
      case notification.target_type
      when "Conversation"
        link = "/conversations/#{notification.target_id}"
      when "Availability"
        link = "/availabilities/#{notification.target_id}"
      when "Feedback"
        link = "/feedbacks/#{notification.target_id}"
      when "FeedbackRequest"
        link = "/feedbacks/#{notification.target.token}"
      else
        link = nil
      end

      # For conversations, also load all messages since last updated
      if(notification.target_type == "Conversation")
        messages = notification.target.messages.where("created_at > ?", notification.updated_at - 1.minute).all
      else
        messages = nil
      end

      if users && users.include?(notification.user)
        notification.update_attribute(:unread, true) unless notification.unread

        np = notification.user.notification_preference
        if np["push_#{notification_code}"]
          self.send_push_notification(notification.user, body, link)
        end
        if np["email_#{notification_code}"]
          self.send_email_notification(notification.user, body, link)
        end
      end

      self.send_faye_notification(notification, messages)

    end

  end


  # Generic function to send any object to any user
  # Can also delete an object from the client side using this
  def self.faye_broadcast(user, object, delete=false, include_notification_counts=false)
    puts "SENDING FAYE MESSAGE"
    if Rails.env == "test" # Disable in test environment
      return
    end
    begin
      data = {}
      key = delete ? :deleteModels : :loadModels
      data[key] = {}
      data[key][object.class.to_s.to_sym] = object.id

      data[:notificationCounts] = user.notification_counts if include_notification_counts

      m = {
        :channel => "/users/#{user.id}/updates",
        :data => data,
        :ext => {:auth_token => FAYE_TOKEN}
      }
      uri = URI.parse("http://localhost:9292/faye")
      Net::HTTP.post_form(uri, :message => m.to_json)
    rescue
      puts "UNABLE TO SEND FAYE MESSAGE"
    end

  end

  # Broadcast the target model and the notification as IDs to be updated on the client side
  def send_faye_notification(notification, extra_objects=nil)
    puts "SENDING FAYE MESSAGE"
    begin

      data = {}
      data[:loadModels] = {}
      data[:loadModels][:notification] = notification.id
      data[:loadModels][target.class.to_s.to_sym] = target.id

      if(extra_objects)
        extra_objects.each do |obj|
          data[:loadModels][obj.class.to_s.to_sym] = obj.id
        end
      end

      user = notification.user

      data[:notificationCounts] = user.notification_counts

      m = {
        :channel => "/users/#{user.id}/updates",
        :data => data,
        :ext => {:auth_token => FAYE_TOKEN}
      }
      uri = URI.parse("http://localhost:9292/faye")
      Net::HTTP.post_form(uri, :message => m.to_json)

    rescue
      puts "UNABLE TO SEND FAYE MESSAGE"
    end
  end


  # Generic method to post to a Pushbots API
  def self.pushbots_api(url, opts={})
    begin
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host)
      request = Net::HTTP::Post.new(uri.request_uri)
      if Rails.env == 'production'
        request["x-pushbots-appid"] = "5526d36017795905498b4580"
        request["x-pushbots-secret"] = "46ef6a7a6548800948b40f9846668519"
      else
        request["x-pushbots-appid"] = "568ecf7f1779592c338b4567"
        request["x-pushbots-secret"] = "8a25aab58e55347d3555bf48a0474c30"
      end

      request["Content-Type"] = "application/json"
      request.set_form_data(opts)
      response = http.request(request)
    rescue
    end
  end


  # Generic function to send a push notification
  # If a link is specified, open that page when they click OK
  def send_push_notification(user, message, link=nil)
    puts "SENDING PUSH NOTIFICATION"

    opts = {
      "msg" => message,
      "alias" => user.email,
      "platform" => [0,1],
      "badge" => user.notification_counts[:all]
    }
    if !link.nil?
      opts["payload['link']"] = link
    end

    ObjectActivity.pushbots_api("http://api.pushbots.com/push/all", opts)

  #   begin
  #     uri = URI.parse("http://api.pushbots.com/push/all")
  #     http = Net::HTTP.new(uri.host)
  #     request = Net::HTTP::Post.new(uri.request_uri)
  #     if Rails.env == 'production'
  #       request["x-pushbots-appid"] = "5526d36017795905498b4580"
  #       request["x-pushbots-secret"] = "46ef6a7a6548800948b40f9846668519"
  #     else
  #       request["x-pushbots-appid"] = "568ecf7f1779592c338b4567"
  #       request["x-pushbots-secret"] = "8a25aab58e55347d3555bf48a0474c30"
  #     end
  #
  #     request["Content-Type"] = "application/json"
  #     opts = {
  #       "msg" => message,
  #       "alias" => user.email,
  #
  #       "platform" => [0,1],
  #       "badge" => user.notification_counts[:all]
  #
  #       # "payload['mytest']" => 'My Test'
  #       #      "sound" => "event",
  #
  #       # Below options don't seem to work...
  #       # "OpenURL" => "users",
  # #      "payload" => {"OpenURL" => "http://google.com"}.to_json
  #     }
  #     if !link.nil?
  #       opts["payload['link']"] = link
  #     end
  #     request.set_form_data(opts)
  #     response = http.request(request)
  #     #puts response
  #   rescue
  #   end
  end

  def send_email_notification(user, message, link=nil)
    UserMailer.send_notification(user, message, link).deliver_later
  end

end
