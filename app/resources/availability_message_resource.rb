class AvailabilityMessageResource < JSONAPI::Resource

  has_one :user
  has_one :availability

  attributes :body, :created_at

  filters :user_id, :availability_id
end
