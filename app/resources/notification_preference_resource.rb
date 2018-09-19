class NotificationPreferenceResource < JSONAPI::Resource

  NotificationPreference::ALL_FIELDS.each do |field|
    attribute field
  end

  filter :user_id

end
