class AvailabilityItemResource < JSONAPI::Resource

  has_one :availability
  has_one :user
  has_one :item, polymorphic: true#, foreign_key: 'resource_id', foreign_type: 'resource_type'

  attributes :name, :notes, :created_at, :updated_at
end
