class LocationResource < JSONAPI::Resource
  attributes :name, :latitude, :longitude

  has_many :user_locations
  has_many :users
end
