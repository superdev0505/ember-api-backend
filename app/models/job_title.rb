class JobTitle < ApplicationRecord

  has_many :users

  has_many :availability_job_titles
  has_many :availabilities, through: :availability_job_titles

  default_scope{ order(:position) }

  validates_uniqueness_of :name
end
