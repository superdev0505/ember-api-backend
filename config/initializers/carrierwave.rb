require 'yaml'
# Load passwords
#passwords = YAML.load_file('./config/passwords.yml')

AWS_CREDENTIALS = {
  # Configuration for Amazon S3 should be made available through an Environment variable.

  # Configuration for Amazon S3
  :provider              => 'AWS',
  :aws_access_key_id     => ENV['S3_KEY'] || "",
  :aws_secret_access_key => ENV['S3_SECRET'] || "",
  :region                => ENV['S3_REGION'] || ""
}

CarrierWave.configure do |config|

  config.fog_provider = 'fog/aws'
  config.fog_credentials = AWS_CREDENTIALS

  # For testing, upload files to local `tmp` folder.
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
    config.root = "#{Rails.root}/tmp"
  else
    config.storage = :fog
  end

  config.cache_dir = "#{Rails.root}/tmp/uploads"                  # To let CarrierWave work on heroku

  config.fog_directory    = "#{ENV['S3_BUCKET_NAME']}-#{Rails.env}"
  # config.s3_access_policy = :public_read                          # Generate http:// urls. Defaults to :authenticated_read (https://)
  # config.fog_host         = "#{passwords['S3_ASSET_URL']}/#{passwords['S3_BUCKET_NAME']}"
end
