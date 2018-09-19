require 'yaml'
#passwords = YAML.load_file('./config/passwords.yml')

########### RESQUE ############

# Resque.redis = 'http://localhost:6379'
# Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }


# ActiveJob::Base.queue_adapter = :resque


########### SIDEKIQ ############

# if Rails.env == 'production'
if Rails.env != 'test'
  ActiveJob::Base.queue_adapter = :sidekiq
else
  ActiveJob::Base.queue_adapter = :inline
end

# Redis config - in live production use Elasticache as environment variables
# Authentication handled by AWS systems
#REDIS_URL = "redis://localhost:6379"
#REDIS_PASSWORD = nil
REDIS_URL = ENV["REDIS_URL"] || "localhost"
REDIS_PORT = ENV["REDIS_PORT"] || "6379"


if Rails.env != 'test'
  Sidekiq.configure_server do |config|
    config.redis = { url: "redis://#{REDIS_URL}:#{REDIS_PORT}" }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: "redis://#{REDIS_URL}:#{REDIS_PORT}" }
  end
end
