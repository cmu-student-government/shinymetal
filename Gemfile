source 'https://rubygems.org'
gem 'rails', '4.2.1'

# Database gems
  # Mysql is being used on our production server
  gem 'mysql2', group: :production

  # Use sqlite3 in development for easy use
  gem 'sqlite3', group: [:development, :test]


# Asset gems
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 5.0'

  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'

  # Use CoffeeScript for .coffee assets and views
  gem 'coffee-rails', '~> 4.1.0'

  # Use Bourbon for SCSS vendor prefix mixins
  gem 'bourbon'

  # Use jquery as the JavaScript library
  gem 'jquery-rails'
  # gem 'jquery-ui-rails', '~> 4.2.1'
  # gem 'jquery-turbolinks'

  # Foundation gems
  gem 'foundation-rails', '= 5.5.1.0'


# API gems
  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
  gem 'jbuilder', '~> 2.0'

  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0', group: :doc

  # Use ActiveModel has_secure_password
  # gem 'bcrypt', '~> 3.1.7'

  # Use Unicorn as the app server
  # gem 'unicorn'

  # Use Capistrano for deployment
  # gem 'capistrano-rails', group: :development


# Utility gems
  # Pagination gem that is still being maintained
  gem 'kaminari'

  # Authorization gem
  gem 'cancancan', '~> 1.10'

  # Error handler
  gem 'gaffe'

  # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
  # gem 'turbolinks'

  # Gives us access to students names/info from CMU's LDAP service
  gem 'cmu_person'

  # Nested filter forms
  gem 'cocoon'
  
  # Markdown rendering
  gem 'redcarpet'

group :development do
  gem 'rails_layout'
  gem 'web-console', '~> 2.0'

  # You need to install other system dependencies. See https://github.com/preston/railroady
  gem 'railroady' # use w/ rake diagram:all

  # The following gems were taken straight from Prof H's gemfiles
  gem 'quiet_assets'
  gem 'thin'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'wirble'
  gem 'hirb'
  gem 'populator3'
  gem 'faker'

  # letter_opener safely opens development emails in browser, does not send.
  # Dev emails are stored in tmp/letter_opener
  gem 'letter_opener'
end

group :test do
  gem 'shoulda'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'mocha', require: false
  gem 'simplecov'
  gem 'single_test'

  # This one is NOT from Prof H, replaces turn gem, turn gem is deprecated
  gem 'minitest-reporters'
  # gem 'tconsole'  # issues with matchers and minitest, so skip for now
end
