# https://codeclimate.com
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.start 'rails'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Nice formatting of errors
require "minitest/reporters"
Minitest::Reporters.use!

# Requiring contexts file
require 'contexts'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Contexts for factory girl testing
  include Contexts

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # Commenting out fixtures
  # fixtures :all

  # Helper method for context tests
  def deny(condition)
    # a simple transformation to increase readability IMO
    assert !condition
  end
end
