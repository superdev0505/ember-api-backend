class CacheConversationMembers < ActiveRecord::Migration[5.0]
  # This is a utility migration - it simply runs cache_active_users! on all conversation objects

  def up
    Conversation.all.each do |c|
      c.cache_active_users!
    end
  end

  def down
  end
end
