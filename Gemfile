source "https://rubygems.org"

# Rails core framework
gem "rails", "~> 8.1"

# Database Adapter
gem "pg", "~> 1.1"

# Web Server & Deployment
gem "puma", ">= 5.0"
gem "kamal" # Kamal deployment

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Core Solid Stack (Jobs, Cache, Cable) - Rails 8 Standard
gem "solid_queue"
gem "solid_cache"
gem "solid_cable"

gem "jbuilder"

# Pagination for list endpoints; JSON meta matches pod_admin_api (num_pages/num_results/current_page)
gem "kaminari"

# Friendly search/filter params mapped to SQL, same pattern as podfoods_api
gem "ransack"

# Cursor pagination for catalog list endpoints [https://github.com/healthie/activerecord_cursor_paginate]
gem "activerecord_cursor_paginate"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Auth for Customer + AdminUser scopes, static non-rotating tokens [https://github.com/lynndylanhurley/devise_token_auth]
gem "devise"
gem "devise_token_auth"

# HTTP client for the Flowspace GraphQL API — same stack podfoods_api uses [https://github.com/lostisland/faraday]
gem "faraday"
gem "faraday-retry"

# API Helpers & Security
gem "rack-cors"
gem "bcrypt", "~> 3.1.7"

group :development, :test do
  # Deploy this application anywhere as a Docker container [https://kamal-deploy.org].
  # Needed on deploy machines, not inside the production app image.
  gem "kamal", require: false

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Interactive debugger: drop `binding.pry` in Ruby/RSpec [https://github.com/pry/pry]
  gem "pry"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # RSpec request specs + generated OpenAPI docs [https://github.com/rspec/rspec-rails] [https://github.com/exoego/rspec-openapi]
  gem "rspec-rails"
  gem "rspec-openapi"
  gem "dotenv-rails"

  # Test data builders for acceptance specs [https://github.com/thoughtbot/factory_bot_rails]
  gem "factory_bot_rails"

  # let_it_be: create test data once per example group, rolled back per example [https://github.com/test-prof/test-prof]
  gem "test-prof"
end

group :test do
  # Record/replay real external API responses (e.g. Stripe) instead of stubbing the SDK [https://github.com/vcr/vcr]
  gem "vcr"
  gem "webmock"
end
