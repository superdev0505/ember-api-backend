class AddAdminToConversationMembers < ActiveRecord::Migration[5.0]
  def up
    add_column :conversation_members, :admin, :boolean, default: false

    # Make everyone admins!
    ConversationMember.all.each{|a| a.update_attribute(:admin, true)}
  end

  def down
    remove_column :conversation_members, :admin
  end
end
