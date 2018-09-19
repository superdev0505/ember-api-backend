class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def to_jsonapi
    resource = eval("#{self.class.to_s}Resource")
    JSONAPI::ResourceSerializer.new(resource).serialize_to_hash(resource.new(self, nil))
  end
end
