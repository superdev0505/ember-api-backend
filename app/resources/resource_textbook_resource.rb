class ResourceTextbookResource < JSONAPI::Resource

  has_one :user
  attributes :name, :isbn, :kortext_link, :img_link, :description, :created_at, :updated_at

end
