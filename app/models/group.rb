class Group < ApplicationRecord

  belongs_to :user
  has_many :group_members
  has_many :users, through: :group_members

  def add_user(user)
    join = group_members.where(:user_id => user.id).first
    group_members.create!(:user_id => user.id) if join.nil?
  end

  def remove_user(user)
    join = group_members.where(:user_id => user.id).first
    join.destroy if join
  end

end
