class EmailAccount < ApplicationRecord

  belongs_to :user

  validates_uniqueness_of :email

  validates_format_of :email, :with => Devise::email_regexp


  # Regex objects to match allowed email addresses (.ac.uk, .nhs.net etc.)
  ALLOWED_EMAILS = [
    /\b[a-z0-9._%+-]+@[a-z0-9._%+-]+\.ac\.uk\b/,
    /\b[a-z0-9._%+-]+@nhs\.net\b/,
    /\b[a-z0-9._%+-]+@nhs\.uk\b/,
    /\b[a-z0-9._%+-]+@doctors\.net\b/, /\b[a-z0-9._%+-]+@doctors\.net\.uk\b/, /\b[a-z0-9._%+-]+@doctors\.org\b/, /\b[a-z0-9._%+-]+@doctors\.org\.uk\b/,
    /\b[a-z0-9._%+-]+@[a-z0-9._%+-]+\.nhs\.uk\b/,
    /\b[a-z0-9._%+-]+@oslr\.co\.uk\b/,
    /\b[a-z0-9._%+-]+@kortext\.com\b/,
    /\b[a-z0-9._%+-]+@e-lfh\.org\.uk\b/
  ]


  # Accounts are verified if they are confirmed and match @nhs.net, @ac.uk etc.
  def check_verified
    if confirmed
      self.verified = ALLOWED_EMAILS.any?{|reg| !(email.downcase =~ reg).nil?}
      if self.verified & !user.verified
        user.update_attribute(:verified, true)
      end
    else
      self.verified = false
    end
    true
  end
  before_save :check_verified

  # Make a confirmation_token on Create
  def make_confirmation_token
    token = Devise.friendly_token
    self.confirmation_token = token
  end
  before_create :make_confirmation_token

  # Make a confirmation_code on Create - used for new code-based system
  def make_confirmation_code
    code = 5.times.map { [*'0'..'9'].sample }.join
    self.confirmation_code = code
  end
  before_create :make_confirmation_code

  def send_confirmation_email
    UserMailer.confirm_email(self).deliver_later
  end
  after_create :send_confirmation_email

  # Occurs when the user clicks the confirmation link
  def confirm!
    update_attribute(:confirmed, true)
    user.update_attribute(:confirmed_at, Time.now) if user.confirmed_at.blank?
    ObjectActivity.faye_broadcast(user, self)
  end

  # Testing utility function
  # Unconfirm the email and the user
  def unconfirm!
    update_attribute(:confirmed, false)
    if(user.email_accounts.where(confirmed: true).first == nil)
      user.update_attribute(:confirmed_at, nil)
    end
  end

  def make_primary!
    user.email_accounts.each{|a| a.update_attribute(:primary, false)}
    update_attribute(:primary, true)
    user.update_attribute(:email, email)
  end


  # FOR TESTING ONLY
  # Updates all email accounts to end @oslr.co.uk
  # Stops sending emails to real users in testing environments
  def self.make_all_safe!
    raise "Can't make emails safe in production environment" if Rails.env == 'production'
    EmailAccount.all.each do |em|
      new_email = [em.email.split("@")[0], "oslr.co.uk"].join("@")
      while User.where(email: new_email).first do
        new_email = "_#{new_email}"
      end
      if em.primary
        em.user.skip_reconfirmation!
        em.user.email = new_email
        counter = 0
        puts "Unable to save user #{em.user.id} : #{em.user.email}" unless em.user.save
      end
      em.update_attribute(:email, new_email)
    end
  end

end
