class AvailabilityRequestVote < ApplicationRecord
  belongs_to :user
  belongs_to :availability_request, counter_cache: true

  # Update the availability request client side on a new request
  def websocket_update
    availability_request.websocket_update
  end
  after_create :websocket_update
end
