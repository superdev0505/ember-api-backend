class ConversationMemberResource < JSONAPI::Resource

  attributes :admin, :updated_at, :created_at

  has_one :conversation
  has_one :user

  paginator :offset

  filter :user_id
  filter :conversation_id

  filter :search, apply: ->(records, value, _options){
    value = value[0] if value.is_a?(Array)
    return records if value.blank?
    q = "%#{value}%"
    puts "FILTERING BY #{q}"
    return records.joins(:conversation => {:conversation_members => :user}).where(['conversations.name LIKE ? OR users.name LIKE ?', q, q])
  }
end
