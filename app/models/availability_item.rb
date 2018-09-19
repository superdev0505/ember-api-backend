class AvailabilityItem < ApplicationRecord

  self.table_name = "availability_resources"

  belongs_to :availability
  belongs_to :item, polymorphic: true#, foreign_key: "resource_id", foreign_type: "resource_type"
  belongs_to :user
end
