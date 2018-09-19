class AvailabilityJobTitle < ApplicationRecord

  belongs_to :availability
  belongs_to :job_title
  
end
