class UserResource < JSONAPI::Resource
  attributes :name, :email, :bio, :confirmed, :terms, :gmc, :password, :password_confirmation,
    :avatar_url, :has_avatar

  paginator :offset

  filter :name_or_email, apply: ->(records, value, _options) {
    value = value[0] if value.is_a?(Array)
    q = "%#{value}%"
    records.where(['users.name LIKE ? OR users.email LIKE ?', q, q])
  }

  filter :name, :email

  filter :exclude, apply: ->(records, value, _options){
    puts "*************** VALUE: #{value}"
    value = value[0] if value.is_a?(Array) && value[0].is_a?(Array)
    records.where(["users.id NOT IN (?)", value.map(&:to_i)])
  }

  # Don't send any passwords...
  def fetchable_fields
    super - [:password, :password_confirmation]
    # if (context[:current_user].guest)
    #   super - [:email]
    # else
    #   super
    # end
  end

  def self.updatable_fields(context)
    super - [:confirmed, :has_avatar, :avatar_url]
  end

  has_one :job_title
  has_many :user_locations
  has_many :locations
  has_many :email_accounts

  def confirmed
    @model.confirmed?
  end

  def has_avatar
    !@model.avatar.blank?
  end

  def avatar_url
    @model.avatar.blank? ? "/assets/placeholder_user_64.png" : @model.avatar.url
  end


  # # For testing purposes, set confirmation codes to 12345 when created from a test environment
  after_create do
    if Rails.env != 'production'
      @model.email_accounts.first.update_attribute(:confirmation_code, "12345") if context[:app_environment] == "test"
    end
  end

end
