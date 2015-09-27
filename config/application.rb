require File.expand_path('../boot', __FILE__)
require 'yaml'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


ENV.update YAML.load_file('config/settings.yml')[Rails.env] rescue {}
ENV['api_key_salt'] = ENV["api_key_salt"] if Rails.env.test?

module Shinymetal
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.autoload_paths += Dir["#{config.root}/lib/autoload/**/"]

    # Treat CanCan's error like a typical Forbidden error
    config.action_dispatch.rescue_responses.merge! 'CanCan::AccessDenied' => :forbidden

    # For Foundation 5
    config.assets.precompile += %w( vendor/modernizr )
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
  end
end
