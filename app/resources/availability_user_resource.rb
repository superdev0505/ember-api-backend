class AvailabilityUserResource < JSONAPI::Resource

  has_one :user
  has_one :availability
  has_one :inviter, class_name: 'User'

  attributes :admin, :teacher, :aasm_state, :created_at, :updated_at
end
