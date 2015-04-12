require 'test_helper'

class PageTest < ActiveSupport::TestCase
  # Pages are independent of all other functionality,
  # so they are not created with other objects.
  context 'Creating a pages context' do
    setup do
      @welcome = Page.find_or_create("welcome")
    end
    
    teardown do
      @welcome.destroy
    end
    
    should "have find_or_create method that returns nil if the requested page is invalid" do
      # Test that the page url "invalid_url" does not have a page
      assert_equal nil, Page.find_or_create("invalid_url")
      # Verify that no new pages were created
      assert_equal 1, Page.all.size
    end
    
    should "have find_or_create method that finds existing page" do
      # Test that @welcome, already created, is found and returned
      assert_equal @welcome, Page.find_or_create("welcome")
      # Verify that no new pages were created
      assert_equal 1, Page.all.size
    end
    
    should "have find_or_create_method that creates a valid page if it doesnt exist yet" do
      # @contact shouldn't exist yet
      assert @contact.nil?
      # "contact" is one of the possible valid page urls.
      @contact = Page.find_or_create("contact")
      assert_equal "Contact Us", @contact.name
      # Verify that 1 new page was created
      assert_equal 2, Page.all.size
    end
  end
end
