source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'

gem 'mysql2'

# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem "rack-cors", require: "rack/cors"

# Devise for user authentication
gem 'devise'

# jsonapi-resources as a serializer
# gem 'jsonapi-resources', git: "https://github.com/cerebris/jsonapi-resources", branch: 'rails5'
gem 'jsonapi-resources', git: "https://github.com/adamp83/jsonapi-resources"

# Handle file and image uploads
gem 'carrierwave'
gem 'fog-aws'
gem 'rmagick', '2.13.4'

gem 'sidekiq'

# Generate avatar images from initials
gem 'avatarly'

# Tracking data with Ahoy
gem 'ahoy_matey'
gem 'uuidtools'

# State machines with AASM
gem 'aasm'

# PDF generator
gem 'wkhtmltopdf-binary'
gem 'pdfkit'

# Use Capistrano for deployment
gem 'capistrano', '~> 3.6'
#gem 'capistrano-rbenv'
gem 'capistrano-rails', '~> 1.2'
gem 'capistrano-rvm'
gem 'capistrano-passenger'


# Test coverage
gem 'simplecov', require: false, group: :test

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

gem 'listen', '~> 3.0.5'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
