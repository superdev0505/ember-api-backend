class NotificationPreference < ApplicationRecord

  belongs_to :user

  # Define possible fields. For each field there is a push_ and a email_ option.
  FIELDS = [:conversation_create, :availability_create, :availability_invite,
    :feedbackrequest_create, :feedback_create, :availability_sign_up, :availability_cancel,
    :availability_create_resource, :availability_update, :availability_destroy,
    :availabilityrequest_create,
    :availability_accept_invite, :availability_reject_invite]

  ALL_FIELDS = FIELDS.collect{|a| "push_#{a}".to_sym} + FIELDS.collect{|a| "email_#{a}".to_sym}
end
