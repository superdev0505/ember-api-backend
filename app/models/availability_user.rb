require 'aasm'

# Join model connecting Availabilities with users
# Can represent invited users, interested users, confirmed or cancelled
# States:
# => interested - signed up to a proposed session
# => invited - invited by someone else to a session (propsed or confirmed)
# => confirmed - confirmed as available
# => cancelled - was confirmed, now cancelled
# => rejected - was invited, now cancelled
class AvailabilityUser < ApplicationRecord

  belongs_to :availability
  belongs_to :user
  belongs_to :inviter, class_name: 'User'

  # Define states:
  include AASM
  aasm do
    state :interested, :initial => true
    state :new, :invited, :confirmed, :cancelled, :rejected, :attended, :dna


    event :confirm do
      transitions from: [:interested, :invited], to: :confirmed
    end

    event :cancel, before: :do_cancel! do
      transitions from: :confirmed, to: :cancelled
    end

    event :reject do
      transitions from: :invited, to: :rejected
    end

  end


  # Notify people when these are created
  # Who is notified depends on the aasm_state
  #after_create :notify
  around_save :notify
  def notify
    # puts "CALLING NOTIFY #{aasm_state}"

    is_new = new_record?
    changed = aasm_state_changed?
    old_state = aasm_state_was

    yield

    # If something has changed, generate alerts below
    return false if !is_new && !changed

    # Update any listening channels
    json = self.to_jsonapi
    # AvailabilityShowUsersChannel.broadcast_to(availability, json)

    # Update anyone in the same location...
    availability.watching_users.each do |user|
      UpdatesChannel.broadcast_to(user, {loadModels: [json]})
    end


    # Now create alert objects
    users = false
    action = nil

    # New records - someone signs up or is invited
    if is_new
      case aasm_state
      when 'interested', 'confirmed'
        # puts "CASE 1"
        # Someone has signed up - alert the session admins. Don't alert the person signing up.
        users = availability.admins - [user]
        message = "#{user.name} signed up to your teaching session"
        action = "sign_up"
      when "new"
        # Someone has been invited - notify them only
        users = [user]
        message = "You have been invited to a teaching session by #{inviter.name}"
        update_attribute(:aasm_state, 'invited')
        action = "invite"
      end
    end

    # State changes
    if !is_new
      # Someone cancels - notify admins
      if aasm_state == 'cancelled'
        users = availability.admins - [user]
        message = "#{user.name} cancelled their attendance at your teaching session"
        action = "cancel"
      end
      # Someone un-cancels
      if old_state == 'cancelled'
        users = availability.admins - [user]
        message = "#{user.name} signed up for your teaching session"
        action = "sign_up"
      end
      # Someone accepts an invitation
      if old_state == 'invited' && %w(interested confirmed).include?(aasm_state)
        users = availability.admins - [user]
        message = "#{user.name} accepted an invitation for your teaching session"
        action = "accept_invite"
      end
      # Someone rejects
      if old_state == 'invited' && aasm_state == 'rejected'
        users = availability.admins - [user]
        message = "#{user.name} cannot make your teaching session"
        action = "reject_invite"
      end
    end

    if users
      CreateAlertsJob.perform_later(users: users, target: availability, action: action, message: message)
    end
  end

  # Create logbook entries after save
  after_save :make_log
  def make_log
    LogbookEntry.make_entry_for(self) if aasm_state == "attended"
  end

  # Make sure there are conversation member objects for all users, if there is a converation associated with the availability
  def ensure_conversation_members
    convo = Conversation.where(availability_id: id).first
    if convo
      convo.conversation_members.create(user: user, admin: admin) if convo.conversation_members.where(user: user).first.nil?
    end
  end
  after_create :ensure_conversation_members

end
