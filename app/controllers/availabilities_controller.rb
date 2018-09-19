class AvailabilitiesController < ApplicationController
  include JSONAPI::ActsAsResourceController

  # Context passed to jsonapi resource objects
  def context
    {
      current_user: current_user,
      app_environment: request.headers["x-vendor-appEnvironment"],
      app_version: request.headers["x-vendor-appVersion"]
    }
  end
end
