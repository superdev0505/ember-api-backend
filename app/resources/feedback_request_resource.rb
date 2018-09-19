class FeedbackRequestResource < JSONAPI::Resource

  attributes :email, :token, :event_description, :event_reflection, :message, :event_time, :completed_at, :created_at, :updated_at

  has_one :availability
  has_one :user
  has_one :target, :class_name => "User"
  has_one :feedback

  filter :token
end
