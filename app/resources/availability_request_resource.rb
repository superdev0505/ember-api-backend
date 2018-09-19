class AvailabilityRequestResource < JSONAPI::Resource

  attributes :info, :created_at, :updated_at, :availability_request_votes_count

  has_one :user
  has_one :location

  has_many :availabilities
  has_many :availability_request_votes

  filters :location_id, :user_id

  # Filter for a user - anything in their locations
  filter :for_user, apply: ->(records, value, _options){
    return records if value.blank?
    value = value[0] if value.is_a?(Array)
    loc_ids = Location.joins(:user_locations).where(:user_locations => {:user_id => value}).select(:id).collect{|a| a.id}
    records.where(location_id: loc_ids)
  }

  # Text query of results
  filter :query, apply: ->(records, value, _options){
    return records if value.blank?
    value = value[0] if value.is_a?(Array)
    records.where(['info LIKE ?', "%"+value+"%"])
  }
end
