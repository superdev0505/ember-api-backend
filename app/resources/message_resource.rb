class MessageResource < JSONAPI::Resource

  attributes :body, :created_at, :updated_at, :conversation_id, :user_id

  has_one :conversation, always_include_linkage_data: true
  has_one :availability, always_include_linkage_data: true
  has_one :user, always_include_linkage_data: true

  filter :conversation_id

  def self.updatable_fields(context)
    super - [:user_id, :created_at, :updated_at]
  end
end
