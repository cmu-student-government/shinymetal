#Copied this test_helper stuff from Prof H files

require 'simplecov'
SimpleCov.start 'rails'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # Commenting out fixtures
  # fixtures :all  

  # Helper method for context tests
  def deny(condition)
    # a simple transformation to increase readability IMO
    assert !condition
  end
end