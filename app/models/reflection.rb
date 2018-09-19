class Reflection < ApplicationRecord

  belongs_to :user

  after_save :make_log
  def make_log
    LogbookEntry.make_entry_for(self)
  end
end
