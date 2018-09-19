require 'yaml'

class CreateAlertsJob < ApplicationJob
  queue_as :default

  # This job is called by Alert.alert!
  # It takes a group of users and a target as input
  # For each user it will:
  # => Create an Alert object pointing at the target
  # => Update the user's websocket channel
  # => Send push notifications / emails depending on the user's notification preferences
  #
  # Some alerts are called in other places:
  # => availability_user model: handles alerts on aasm_state change
  #
  # The method should be passed a hash with available options:
  # => users (required) - which users to alert
  # => target (required) - what to alert about
  # => action (required) - the action resulting in this alert
  # => message (optional) - the alert message. This can be auto-generated but a custom message can be passed.
  def perform(*args)
    # users = args[0]
    # target = args[1]
    # # Allow configuration of the message - this can be nil
    # message = args[2]
    opts = args[0]

    # Check for required options
    users = opts[:users]
    target = opts[:target]
    action = opts[:action]
    message = opts[:message]

    raise("users are a required input to CreateAlertsJob") if users.nil?
    raise("target is a required input to CreateAlertsJob") if target.nil?
    raise("action is a required input to CreateAlertsJob") if action.nil?

    #passwords = YAML.load_file("#{Rails.root}/config/passwords.yml")

    # Figure out the read link and message from the target
    case target.class.to_s
    when 'Message'
      conversation = target.conversation
      read_link = conversation.availability_id.nil? ? "/app/main/conversations/show/#{conversation.id}" : "/app/main/availabilities/#{conversation.availability_id}/messages"
      message = "#{target.user.first_name}: #{target.body}" unless message
    when 'Availability'
      # There are multiple reasons to alert about an availability (creation, sign ups, changes etc.) so the message must be passed in
      read_link = "/app/main/availabilities/#{target.id}/index"
      # case action
      # when 'sign_up'
      #   message = "#{user.name} signed up to your teaching session"
      # when 'invite'
      #   message = "You have been invited to a teaching session by #{inviter.name}"
      # end
      message = message
    when 'FeedbackRequest'
      read_link = "/feedback-requests/show/#{target.token}"
      message = "#{target.user.first_name} requested feedback"
    when 'Feedback'
      read_link = "/app/main/feedbacks/show/#{target.id}"
      message = "Feedback received from #{target.user.name}"
    end

    users = [users] if users.is_a?(User)

    # This list can be long. For testing purposes, only alert the first 5.

    users.each_with_index do |user, i|

      # if Rails.env == 'test' && i > 5
      #   break
      # end

      a = Alert.create!(
        user: user,
        target: target,
        read_link: read_link,
        text: message,
        action: action
      )

      # Determine whether to send email / push based on user preferences
      # The relevant fields should be:
      # => push_#{target_type}_#{action}
      # => email_#{target_type}_#{action}
      prefs = user.notification_preference

      ttype = target.class.to_s

      # This is a hack for the old method of storing conversation_create instead of message_create in notification preferences
      ttype = "Conversation" if ttype == "Message"

      push_pref = prefs["push_#{ttype.downcase}_#{action.downcase}".to_sym]
      email_pref = prefs["email_#{ttype.downcase}_#{action.downcase}".to_sym]

      # Don't do alerts in test environment
      return false if Rails.env == 'test'

      # Send push notifications
      # The DELIVER_PUSH_NOTIFICATIONS variable is set in environments/*.rb
      if push_pref && DELIVER_PUSH_NOTIFICATIONS
        puts "SEND PUSH FOR #{user.name}"

        opts = {
          "msg" => message,
          "alias" => user.email,
          "platform" => [0,1],
          "badge" => user.notification_counts[:all]
        }
        if !read_link.nil?
          opts["payload['link']"] = read_link
        end

        url = "http://api.pushbots.com/push/all"

        begin
          uri = URI.parse(url)
          http = Net::HTTP.new(uri.host)
          request = Net::HTTP::Post.new(uri.request_uri)
          if Rails.env == 'production'
            # TODO: not yet production ready! Currently set to dev defaults
            request["x-pushbots-appid"] = ENV['PUSHBOTS_KEY']
            request["x-pushbots-secret"] = ENV['PUSHBOTS_SECRET']
          else
            request["x-pushbots-appid"] = ENV['PUSHBOTS_KEY']
            request["x-pushbots-secret"] = ENV['PUSHBOTS_SECRET']
          end

          request["Content-Type"] = "application/json"
          request.set_form_data(opts)
          response = http.request(request)
        rescue
        end
      end

      # Sent email
      if email_pref
        puts "SEND EMAIL FOR #{user.name}"
        UserMailer.send_notification(user, message, read_link).deliver_later
      end

    end
  end
end
