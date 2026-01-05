source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.8'
gem "dotenv-rails", require: 'dotenv/rails-now'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 1.5'
# Use Puma as the app server
gem 'puma', '>= 6.4.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'rswag-api'
gem 'rswag-ui'
gem 'devise'
gem 'doorkeeper'

gem 'dry-initializer'
gem 'dry-struct'
gem 'dry-monads'
gem 'rack-cors'
gem 'telegram-bot-ruby', '~> 2.5'
gem 'metainspector', '~> 5.16'
gem "aws-sdk-s3", require: false

gem "nokogiri", '>= 1.16'
gem 'concurrent-ruby', '1.3.4'
gem 'mutex_m'
gem 'tsort'
gem 'ostruct'
gem 'base64'
gem 'csv'
gem 'observer'
gem 'getoptlong'
gem 'syslog'
gem 'abbrev'
gem 'drb'
gem 'prime'
gem 'benchmark'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rswag-specs'
  gem 'rspec-rails'
  gem 'factory_bot'
  gem 'faker'
  gem 'pry-rails'
  gem 'simplecov'
  gem 'factory_bot_rails'
  gem 'rubocop'
end

group :development do
  gem 'listen', '>= 3.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'bundle-audit'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "rubocop-faker", "~> 1.0"

gem "down", "~> 5.4"
