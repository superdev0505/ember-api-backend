class UserInterest < ApplicationRecord
  
  belongs_to :user, :counter_cache => true
  belongs_to :interest, :class_name => "Specialty", :foreign_key => :specialty_id
  
end
