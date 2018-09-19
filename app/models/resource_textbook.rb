class ResourceTextbook < ApplicationRecord
  belongs_to :user
  has_many :availability_items, as: :item
end
