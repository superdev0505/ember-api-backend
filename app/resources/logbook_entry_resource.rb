class LogbookEntryResource < JSONAPI::Resource

  attributes :entry_type, :subject, :date, :created_at, :updated_at, :target_id

  has_one :user
  has_one :target, polymorphic: true
  has_one :availability
  # has_one :reflection

  filters :user_id, :entry_type

  filter :start_date, apply: ->(records, value, _options){
    return records if value.blank?
    records.where('logbook_entries.date > ?', Date.parse(value.to_s))
  }
  filter :end_date, apply: ->(records, value, _options){
    return records if value.blank?
    records.where('logbook_entries.date < ?', Date.parse(value.to_s) + 1.day)
  }

  paginator :offset
end
