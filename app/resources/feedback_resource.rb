class FeedbackResource < JSONAPI::Resource

  attributes :created_at

  has_one :user
  has_one :target, :class_name => "User"
  has_one :availability

  has_many :feedback_question_responses

  filters :user_id, :target_id

  filter :query, apply: ->(records, value, _options){
    return records if value.blank?
    value = value[0] if value.is_a?(Array)
    value = "%" + value + "%"
    puts "VALUE: #{value}"
    records.joins(:user).joins(:availability).joins(:feedback_question_responses).where(['users.name LIKE ? OR availabilities.info LIKE ? OR feedback_question_responses.body LIKE ?', value, value, value])
  }

end
