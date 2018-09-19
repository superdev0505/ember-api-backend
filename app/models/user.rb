class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable


  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => Devise::email_regexp


  before_save :ensure_authentication_token
  before_save :ensure_filters

  alias_attribute :user_email, :email

  mount_uploader :avatar, AvatarUploader

  belongs_to :job_title

  has_many :conversation_members
  has_many :conversations, through: :conversation_members
  has_many :messages, :foreign_key => :author_id

  has_many :contacts
  has_many :friends, :through => :contacts
  has_many :groups

  has_many :feedback_requests
  has_many :feedbacks, :foreign_key => :user_id
  has_many :feedbacks_received, :foreign_key => :target_id, :class_name => "Feedback"

  has_many :feedback_requests_received, :class_name => "FeedbackRequest", :foreign_key => :target_id

  has_many :notifications

  has_many :user_locations
  has_many :locations, through: :user_locations

  has_many :user_specialties
  has_many :specialties, through: :user_specialties

  has_many :user_interests
  has_many :interests, through: :user_interests, :class_name => "Specialty"

  has_many :availabilities # When I am available

  has_many :availability_students # Sessions signed up to

  has_many :availability_invites, foreign_key: :student_id # Sessions invited to

  has_many :reflections
  has_many :logbook_entries

  has_many :email_accounts

  has_many :certificates

  has_many :visits
  has_many :ahoy_events, through: :visits, class_name: "Ahoy::Event"

  belongs_to :notification_preference

  has_many :availability_users
  has_many :availabilities, through: :availability_users


  has_many :alerts

  # By default, a email_account object should be created on user creation
  def setup_email_account
    email_accounts.create!(email: email, primary: true, confirmed: !confirmed_at.blank?)
  end
  after_create :setup_email_account

  def primary_email_account
    email_accounts.where(primary: true).first
  end

  # Make sure there is an object to store notification preferences
  def setup_notification_preferences
    n = NotificationPreference.create!(user_id: id)
    self.notification_preference_id = n.id
  end
  before_create :setup_notification_preferences

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def experience_level
    job_title.nil? ? 0 : job_title.position
  end


  def filter_locations
    filter_locations_str.blank? ? [] : Location.find(filter_locations_str.split(","))
  end

  def filter_specialties
    filter_specialties_str.blank? ? [] : Specialty.find(filter_specialties_str.split(","))
  end


  # Generate notification objects for this user for availabilities, based on their preferences
  # Destroy inappropriate notification objects
  def generateAvailabilityNotifications(limit=nil, offset=nil)

    # Find suitable availabilities
    # Don't show anything if they haven't picked a job title yet
    if job_title && verified
      myavailabilities = Availability.where(:is_private => false).offset(offset).limit(limit)

      myavailabilities = myavailabilities.where(
      ["target_experience_min <= ? AND target_experience_max >= ?",
        job_title.position, job_title.position]
      )

      # Filter by location
      loc_ids = locations.collect{|a| a.id}
      myavailabilities = myavailabilities.where(:location_id => loc_ids)

      # Filter by specialties they're interested in
      unless interests.blank?
        ids = interests.collect{|a| a.id}
        myavailabilities = myavailabilities.joins(:availability_specialties).where(:availability_specialties => {:specialty_id => ids})
      end

      myavailabilities = myavailabilities.offset(offset).limit(limit).all
    else
      myavailabilities = []
    end

    # TODO hospitals and specialties

    # Make sure anything they've created is included
    myavailabilities += availabilities.offset(offset).limit(limit)

    # Make sure anything they've signed up to is included
    myavailabilities += availability_students.offset(offset).limit(limit).includes(:availability).collect{|a| a.availability}

    # Make sure anything they're invited to is included
    myavailabilities += availability_invites.offset(offset).limit(limit).includes(:availability).collect{|a| a.availability}

    # Delete unwanted notifications
    Notification.where(:user_id => id, :target_type => "Availability").where(
      ["target_id NOT IN (?)", myavailabilities.collect{|a| a.id}]
    ).all.each do |a|
      ObjectActivity.faye_broadcast(self, a, true)
      a.destroy
    end

    all_notifications = Notification.where(user_id: id,
        target_type: "Availability",
        target_id: myavailabilities.uniq.collect{|a| a.id}
      ).all
    myavailabilities.uniq.each do |availability|
      notification = all_notifications.detect{|a| a.target_id == availability.id}
      # notification = Notification.where(:user_id => id, :target => availability).first
      unless notification
        n = Notification.create!(:user_id => id, :target => availability, :unread => false)
        ObjectActivity.faye_broadcast(self, n)
      end
    end
  end
  # Call this in the controller - otherwise it gets called after every sign in!
#  after_save :generateAvailabilityNotifications



  def initials
    name.split.collect{|a| a[0]}.join(" ")
  end

  def generate_avatar
    img = Avatarly.generate_avatar(initials, {
      size: 64,
      background_color: "#FFFFFF",
      font_color: "#00CDD1",
      font: "#{Rails.root}/public/HelveticaNeueThin.ttf"
    })

    # Make a temp file, set the user's avatar flag to it, save the user and delete the temp file
    tmpfilename = "#{Rails.root}/tmp/tmp_avatar_#{id}.png"
    File.open(tmpfilename, 'wb') do |f|
      f.write img
    end
    tmpfile = File.open(tmpfilename)

    self.avatar = tmpfile
    self.save!
    File.delete(tmpfilename) if File.exist?(tmpfilename)
    true
  end
  after_create :generate_avatar


  def notification_counts
    nots = self.notifications.where(:unread => true)
    counts = {}
    counts[:all] = nots.count
    counts[:availability] = nots.where(:target_type => "Availability").count
    counts[:feedback] = nots.where("target_type = ? OR target_type = ?", "Feedback", "FeedbackRequest").count
    counts[:messages] = nots.where(:target_type => "Conversation").count

    counts
  end

  # Similar function for new Alerts system
  def alert_counts
    nots = self.alerts.where(:unread => true)
    counts = {}
    counts[:all] = nots.count("DISTINCT read_link")
    counts[:availabilities] = nots.where(:target_type => "Availability").count("DISTINCT read_link")
    counts[:feedbacks] = nots.where(["target_type = ? OR target_type = ?", "Feedback", "FeedbackRequest"]).count("DISTINCT read_link")
    counts[:messages] = nots.where(:target_type => "Message").count("DISTINCT read_link")

    {alertCounts: counts}
  end


  def add_contact(user)
    return false if user.id == id # Don't add yourself!
    contact = contacts.where(:friend_id => user.id).first
    contacts.create!(:friend_id => user.id) if contact.nil?
  end
  def remove_contact(user)
    contacts.where(:friend_id => user.id).each{|a| a.destroy}
  end

  # Check if this user has any verified email accounts
  def check_verified!
    update_attribute :verified, email_accounts.any?{|a| a.verified}
  end


  # After any change, broadcast the user on Faye to update the client
  # Send to everyone in the same hospital(s)
  def broadcast_after_save
    # ObjectActivity.faye_broadcast(self, self) if verified_changed? | confirmed_at_changed?
    return true unless verified_changed? | confirmed_at_changed? | name_changed? | bio_changed? | job_title_id_changed? | avatar_changed? | gmc_changed?
    # users = User.joins(:user_locations).where(:user_locations => {:location_id => self.locations.collect{|a| a.id}}).all
    # users.each do |u|
    #   UpdatesChannel.broadcast_to(u, {loadModels: [self.to_jsonapi]})
    # end
    BroadcastToLocationJob.perform_later(self.locations.all.to_a, {loadModels: [self.to_jsonapi]})
    true
  end
  after_save :broadcast_after_save


  def send_confirmation_instructions
    email_account = primary_email_account
    UserMailer.confirm_email(email_account).deliver_later

    # unless @raw_confirmation_token
    #   generate_confirmation_token!
    # end
    #
    # opts = pending_reconfirmation? ? { to: unconfirmed_email } : { }
    # send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
  end


  # The first name
  def first_name
    name.split(" ")[0]
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  # Make sure they have filters set up
  def ensure_filters
    min = JobTitle.order(:position).first.position
    max = JobTitle.order(:position).last.position
    self.filter_experience_min = min if filter_experience_min.nil?
    self.filter_experience_max = max if filter_experience_max.nil?
    self.target_experience_min = min if target_experience_min.nil?
    self.target_experience_max = max if target_experience_max.nil?
  end



  def self.getInfoFromEmail(email)
    url = "https://api.fullcontact.com/v2/person.json?email=#{email}&apiKey=d6b52a12e6b6d4c7"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    json = JSON.parse(response.body)
    return false unless json["status"] == 200
    json
  end

  has_many :user_suggested_photos

  # Pre-populate based on email address after successful creation
  after_create :prepopulate
  def prepopulate
    begin
      data = User.getInfoFromEmail(email)
    rescue
      return false
    end
    return false unless data

    # Get a name
#    self.name ||= data["contactInfo"]["fullName"] if data["contactInfo"]

    # Create suggested photo objects for all pictures returned
    if data["photos"]
      data["photos"].each do |photo|
        self.user_suggested_photos.create!(:url => photo["url"], :source => photo["typeName"])
      end
    end

  end


  # Make sure a user has a name attribute
  # Required for dummy users created from an email
  before_save :ensure_name
  def ensure_name
    if name.blank?
      self.name = self.email.split("@")[0].split(".").collect{|a| a.camelize}.join(" ")
    end
    true
  end


  # unless Rails.env == "production"
  #   after_create :confirm!
  # end


  # For stats purposes, count users active in a time period
  def self.count_active_in_period(start_time, end_time=Time.now)
    User.joins(:visits => :ahoy_events).where(["ahoy_events.time > ? AND ahoy_events.time <= ?", start_time, end_time]).uniq.count
  end

  # Shorthand to find in last 24h, 7d etc.
  def self.count_active_since(time)
    User.count_active_in_period(Time.now - time)
  end



  protected
  def confirmation_required?
    false
  end


  # Override this - email is sent on creation of EmailAccount model
  def send_on_create_confirmation_instructions
    false
    # send_confirmation_instructions
  end
  def send_confirmation_notification?
    false
    #confirmation_required? && !@skip_confirmation_notification && self.email.present?
  end
end
