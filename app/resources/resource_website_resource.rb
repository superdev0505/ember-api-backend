class ResourceWebsiteResource < JSONAPI::Resource
  has_one :user
  attributes :name, :url, :description, :created_at, :updated_at
end
