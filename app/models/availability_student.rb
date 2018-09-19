class AvailabilityStudent < ApplicationRecord


  belongs_to :user
  belongs_to :availability

  visitable class_name: "Visit"

  after_save :make_log
  def make_log
    LogbookEntry.make_entry_for(self)
  end


  # Define states:
  include AASM
  aasm do
    state :invited, :initial => true
    state :signed_up, :rejected, :confirmed, :attended, :dna, :cancelled


    # A user accepts an invitation
    # If the session is confirmed, set them to 'confirmed' otherwise to 'signed_up'
    event :accept do
      transitions from: :invited, to: :confirmed, guard: :availability_confirmed?
      transitions from: :invited, to: :signed_up
    end

    # A user rejects an invitation
    event :reject do
      transitions from: :invited, to: :rejected
    end

    # After a date and time is set, a user confirms their attendance
    event :confirm do
      transitions from: [:invited, :signed_up], to: :confirmed
    end

    # When a session is marked as complete, mark who attended
    event :confirm_attended do
      transitions from: [:confirmed, :signed_up], to: :attended
    end
    event :mark_dna do
      transitions from: :confirmed, to: :dna
    end

    # A user cancels
    event :cancel do
      transitions from: [:signed_up, :confirmed], to: :cancelled
    end


  end

  def availability_confirmed?
    %w(confirmed completed).includes?(availability.aasm_state)
  end
end
