class Conversation < ApplicationRecord

  has_many :messages
  has_many :conversation_members
  has_many :users, :through => :conversation_members

  has_many :object_activities, :as => :target

  belongs_to :availability

  default_scope { order(updated_at: :desc) }

  def active_users
    conversation_members.where(:active => true).includes(:user).collect{|a| a.user}.compact.uniq
  end

  # Store the active user IDs as a string separated by commas
  def cache_active_users!
    update_attribute :active_users_cache, conversation_members.where(:active => true).collect{|a| a.user_id}.uniq.compact.sort.join(",")
  end

  # Update notifications updated_at value on change
  has_many :notifications, as: :target
  def update_notifications
    if changed?
      notifications.each{|a| a.update_attribute(:target_updated_at, updated_at)}
    end
  end
  after_save :update_notifications

  # When we search for conversations we search on the ConversationMember object
  # This should match the updated_at variable for all users, so they are ordered correctly
  def update_conversation_members
    conversation_members.each{|a| a.update_attribute(:updated_at, updated_at)}
  end
  after_save :update_conversation_members

end
