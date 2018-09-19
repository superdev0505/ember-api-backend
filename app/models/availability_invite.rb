class AvailabilityInvite < ApplicationRecord

  belongs_to :user
  belongs_to :student, class_name: 'User'
  belongs_to :availability

  # Accept or reject the invite
  def respond!(accept)
    self.responded = true
    self.accepted = accept
    self.save!

    if accept
      availability.sign_up!(student)
    end
  end
end
