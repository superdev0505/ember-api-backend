class BroadcastToLocationJob < ApplicationJob
  queue_as :default

  # This performs websocket updates to everyone in a given location (hospital)
  # First argument is the location, or array of locations
  # Second argument is what to broadcast
  def perform(*args)

    locations = args[0]
    data = args[1]

    locations = [locations] unless locations.is_a?(Array)
    location_ids = locations.collect{|a| a.id}

    users = User.joins(:user_locations).where(:user_locations => {:location_id => location_ids}).all

    users.each do |user|
      UpdatesChannel.broadcast_to(user, data)
    end
  end
end
