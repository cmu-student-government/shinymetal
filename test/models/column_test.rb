require 'test_helper'

class ColumnTest < ActiveSupport::TestCase
  #Relationships
  should have_many(:user_key_columns)
  should have_many(:user_keys).through(:user_key_columns)
  
  context "Creating a columns context" do
    setup do
      create_columns
    end
    
    teardown do
      destroy_columns
    end
    
    should "have a method to return the columns name" do
      assert_equal "organizationId", @organizations_id_column.name
    end
	
    should "have a scope to sort columns alphabetically" do
      assert_equal [ ["events", "eventName"],["organizations", "organizationId"]],
                   Column.alphabetical.to_a.map {|f| [f.resource, f.name]}
    end
    
    should "have a scope to restrict column resources" do
      assert_equal [["organizations", "organizationId"]],
                   Column.alphabetical.restrict_to("organizations").to_a.map {|f| [f.resource, f.name]}
    end
      
    should "have a repopulate method that pulls valid column names from collegiatelink" do
      # Unlike Organization.repopulate (which takes no chances), Column.repopulate assumes that columns are never removed.
      # Thus, remove columns that don't actually exist in the test version of collegiatelink:
      destroy_columns
      # Call it twice, to show that nothing changes
      2.times do
        Column.repopulate
        # All resources in the test version of collegiatelink api have the same 2 columns:
        for resource in Resources::RESOURCE_LIST
          assert_equal ["name","organizationId"], Column.restrict_to(resource).alphabetical.to_a.map{|o| o.column_name}
        end
      end
      Column.destroy_all
      # Put back the other columns
      create_columns
    end
  end
end
