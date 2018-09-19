class ItemsController < ApplicationController
  # Empty class - needed as Item is a polymorphic relationship
  include JSONAPI::ActsAsResourceController
end
