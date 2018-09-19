module Ahoy
  class Event < ApplicationRecord
    self.table_name = "ahoy_events"
    self.primary_key = 'id'

    belongs_to :visit
    belongs_to :user

    serialize :properties, JSON
  end
end
