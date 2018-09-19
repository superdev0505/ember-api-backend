class ConversationResource < JSONAPI::Resource

  attributes :name, :created_at, :updated_at, :messages_count, :active_users_cache

  has_many :conversation_members
  has_one :availability
  has_many :messages

  # TODO: cache user IDs (active users cache)
  # Filter to search by user ID collection

  filter :active_user_ids, apply: ->(records, value, _options){
    return records if value.blank?
    value = [value] unless value.is_a?(Array)
    value = value[0] if value[0].is_a?(Array)
    puts "FILTERING ACTIVE USER IDs #{value} -> #{value.uniq.sort.join(",")}"
    records.where(active_users_cache: value.uniq.sort.join(","))
  }
end
