source 'https://rubygems.org'
gem 'rails', '4.1.1'
gem 'rake', '10.0.4'
gem 'therubyracer', '~> 0.12.1',  platforms: :ruby


# Capistrano for deployment
  gem 'capistrano', '~> 3.4'
  gem 'capistrano-rails', '~> 1.1.2' # Use Capistrano for deployment
  gem 'capistrano-bundler'


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
  gem 'jquery-rails', '~> 3.1.2'
  gem 'jquery-turbolinks'

  # Foundation gems
  gem 'foundation-rails', '= 5.5.1.0'


# API gems
  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
  gem 'jbuilder', '~> 2.0'

  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0', group: :doc


# Utility gems
  # Pagination gem that is still being maintained
  gem 'kaminari'

  # Authorization gem
  gem 'cancancan', '~> 1.10'

  # Error handler
  gem 'gaffe'

  # Load .env files into ENV
  gem 'dotenv-rails', github: "bkeepers/dotenv", tag: 'v2.0.1', require: 'dotenv/rails-now'

  # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
  gem 'turbolinks'

  # Gives us access to students names/info from CMU's LDAP service
  gem 'cmu_person', git: 'https://github.com/jkcorrea/cmu_person.git'
  
  # Nested filter forms
  gem 'cocoon'

  # Markdown rendering
  gem 'redcarpet'

  # Schedules tasks (used for email)
  gem 'whenever', :require => false

  # Sqlite3 for dev, test db
  gem 'sqlite3', group: [:development, :test]

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


group :production, :staging do
  # Use mysql2 for deploy db
  gem 'mysql2'

  # Need this otherwise mod_rails throws a fit on deploy server
  gem 'actionpack-page_caching'
end
