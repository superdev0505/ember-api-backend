class Specialty < ApplicationRecord
  
  has_many :user_specialties
  has_many :users, through: :user_specialties
  
  has_many :availability_specialties
  has_many :availabilities, through: :availability_specialties
  
  validates_uniqueness_of :name
  
end
