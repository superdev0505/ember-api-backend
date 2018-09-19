class Certificate < ApplicationRecord

  belongs_to :user

  has_and_belongs_to_many :logbook_entries

end
