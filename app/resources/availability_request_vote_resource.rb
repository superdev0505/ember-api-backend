class AvailabilityRequestVoteResource < JSONAPI::Resource
  attributes :created_at

  has_one :user
  has_one :availability_request

  filters :user_id, :availability_request_id
end
