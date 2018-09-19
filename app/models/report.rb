class Report < ApplicationRecord

  belongs_to :report_category
  belongs_to :target, polymorphic: true
  belongs_to :user

end
