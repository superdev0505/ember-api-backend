# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class UpdatesChannel < ApplicationCable::Channel
  # UpdatesChannel sends ALL model updates to a given user
  # All users connect to this channel on login and stay connected
  #
  # Data structure in this channel:
  # => loadModels: array, each item has {modelName: X, modelId: Y, updatedAt: Z}
  # => destroyModels: array of {modelName: X, updatedAt: Y}
  # => alertCounts: {all: X, messages: Y, ...}
  #
  # Data should be sent via this channel as follows:
  # => Messaging and feedback updates are sent to the relevant users
  # => Availability updates are sent to all users in the hospital
  #
  # Note that this is NOT the same as push notifications - everyone in the hospital should have up to date data, but the actual alert is sent to those who want it via a different mechanism

  def subscribed
    puts "UPDATE CHANNEL - connected to user #{current_user.id}" if current_user

    stream_for current_user

    # Set up alert counts on initial connection
    json = current_user.alert_counts
    UpdatesChannel.broadcast_to(current_user, json)

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
