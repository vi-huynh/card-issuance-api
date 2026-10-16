source "https://rubygems.org"
gem "rails", "~> 7.2.3", ">= 7.2.3.2"
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # Loads .env files so local (non-Docker) runs pick up the same vars docker-compose injects via env_file
  gem "dotenv-rails"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails", "~> 6.5.1"
  gem "faker", "~> 2.0"
  gem "database_cleaner"
  gem "rspec-openapi"
end

group :development do
  gem "annotate"
  gem "bullet"
end

group :test do
  gem "simplecov", require: false
end

gem "jwt"
gem "pagy", "~> 6.0"
gem "dry-validation"
gem "rswag-ui"
gem "active_model_serializers"
