class ConversationMember < ApplicationRecord

  belongs_to :user
  belongs_to :conversation

  # After any changes, make sure the conversation object caches all active users
  def cache_active_users
    conversation.cache_active_users!
  end
  after_create :cache_active_users
  after_destroy :cache_active_users

  def cache_active_users_if_changed
    if active_changed?
      conversation.cache_active_users!
    end
  end
  after_save :cache_active_users_if_changed

end
