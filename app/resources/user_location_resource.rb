class UserLocationResource < JSONAPI::Resource

  has_one :user
  has_one :location

  filters :user_id, :location_id

  paginator :none
end
