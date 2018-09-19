class AvailabilityResource < JSONAPI::Resource

  attributes :start_time, :end_time, :max_students, :info, :location_info, :aasm_state, :is_private, :created_at, :updated_at

  attribute :completed_notes if ActiveRecord::Migrator.current_version && ActiveRecord::Migrator.current_version >= 20160831212825

  has_one :user
  has_one :location
  if ActiveRecord::Migrator.current_version && ActiveRecord::Migrator.current_version >= 20160830084201
    has_many :availability_users
    has_many :users
  end
  has_many :feedback_requests
  has_many :feedbacks

  has_many :availability_items
  has_many :messages

  # has_many :availability_job_titles
  has_many :job_titles

  has_many :specialties

  def self.default_sort
    [{field: 'start_time', direction: 'desc'}]
  end

  filters :location_id

  paginator :offset

  filter :start_date, apply: ->(records, value, _options){
    return records if value.blank?
    puts "FILTERING START DATE #{value}"
    records.where('availabilities.start_time > ?', Date.parse(value.to_s))
  }
  filter :end_date, apply: ->(records, value, _options){
    return records if value.blank?
    records.where('availabilities.end_time < ?', Date.parse(value.to_s) + 1.day)
  }

  # Show only sessions taught by the logged in user
  filter :filter_type, apply: ->(records, value, _options){
    return records if value.blank?
    value = value[0] if value.is_a?(Array)
    current_user = _options[:context][:current_user]
    # puts "FILTER VALUE: #{value}"
    case value
    when "taught"
      return records.joins(:availability_users).where(:availability_users => {teacher: true, user_id: current_user.id})
    when "attended"
      return records.joins(:availability_users).where(:availability_users => {teacher: false, user_id: current_user.id})
    when "suggested"
      # Return sessions in the future in their locations
      # TODO: add job titles
      # TODO: add specialties

      return records.where(
        location_id: current_user.locations.collect{|a| a.id}
      ).where(
        ["availabilities.end_time > ?", Time.now]
      )
    else
      return records
    end
  }

  filter :query, apply: ->(records, value, _options){
    return records if value.blank?
    value = value[0] if value.is_a?(Array)
    q = "%#{value}%"
    records.where(['availabilities.info LIKE ?', q])
  }

  before_create :set_user_id
  def set_user_id
    @model.user_id = @context[:current_user].id
  end
end
