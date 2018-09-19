require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OslrApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Configure CORS to allow requests from our servers
    config.middleware.use Rack::Cors do
      allow do
        origins "*"
        #origins /((http|https|ws):\/\/(.*?)\.oslr\.co\.uk|(http|https|ws):\/\/locahost(.*?:)+)/
        resource "*", headers: :any, methods: [:get, :post, :put, :delete, :options, :patch], credentials: false
      end
    end

    config.action_dispatch.default_headers = {
      'appEnvironment' => "", # without value
      'appVersion' => ""
    }

    # Allow ActionCable requests from anywhere
    config.action_cable.disable_request_forgery_protection = true

    # if Rails.env == 'production'
    #   Rails.application.config.active_job.queue_adapter = :sidekiq
    # else
    #   Rails.application.config.active_job.queue_adapter = :inline
    # end
  end
end
