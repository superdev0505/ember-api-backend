class SpecialtyResource < JSONAPI::Resource
  attributes :name

  has_many :availabilities
end
