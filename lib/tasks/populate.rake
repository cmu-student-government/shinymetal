namespace :db do
  # Populate file and structure taken from PATS
  # Unfinished
  
  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate'
  # executing 'rake db:populate' will cause this script to run
  task :populate => :environment do
    # Need two gems to make this work: faker & populator
    # Docs at: http://populator.rubyforge.org/
    require 'populator'
    # Docs at: http://faker.rubyforge.org/rdoc/
    require 'faker'
    
    # Step 1: clear any old data in the db
    [Approval, Comment, Filter, Organization, UserKeyFilter, UserKeyOrganization, User, UserKey].each(&:delete_all)
    
    
    # Step 2: Add Filters, Orgs, and Approvers
    # Define resources, filter_names, filter_values
    filter_lists = [["organizations","membershipType","closed"],
                 ["events","currentEventsOnly","true"],
                 ["attendees","status","active"],
                 ["memberships","currentMembershipsOnly","true"],
                 ["positions","type","public"],
                 ["users","status","active"]]
    filter_lists.each do |fl|
      # create a filter
      filter = Filter.new
      filter.resource = fl[0]
      filter.filter_name = fl[1]
      filter.filter_value = fl[2]
      # save with bang (!) so exception is thrown on failure
      filter.save!
    end
    org_lists = [["Tennis","100"],
                 ["Crew","200"],
                 ["Water Polo","300"]]
    org_lists.each do |ol|
      # create an org
      org = Organization.new
      org.name = ol[0]
      org.external_id = ol[1]
      # save with bang (!) so exception is thrown on failure
      org.save!
    end
    # now add approver users
    1..5.times do
      # create a user
      user = User.new
      user.andrew_id = Faker::Internet.user_name
      user.role = "requester"
      user.is_approver = true
      # save with bang (!) so exception is thrown on failure
      user.save!
    end
    
    # and admin user
    admin_user = User.new
    admin_user.andrew_id = "admin"
    admin_user.role = "admin"
    admin_user.is_approver = true
    admin_user.save!
    
    # Step 3: add 20 users
    User.populate 20 do |user|
      # each key needs a role, is_approver, and andrew_id
      # get some fake data using the Faker gem
      user.andrew_id = Faker::Internet.user_name
      user.is_approver = false
      user.role = "requester"
      # set the timestamps
      user.created_at = Time.now
      user.updated_at = Time.now
      
      # Step 3A: add 0 to 3 keys for each user
      UserKey.populate 0..3 do |user_key|
        user_key.user_id = user.id
        # make sure all begin as awaiting submission
        user_key.status = "awaiting_submission"
        # submit some keys randomly
        if [true,false].sample #if submitted....
          # Submitted in past 30 days
          user_key.time_submitted = 3.weeks.ago.to_date
          user_key.status = "awaiting_filters"
          if [true,false].sample #if filters applied...
            user_key.time_filtered = 2.weeks.ago.to_date
            user_key.status = "awaiting_confirmation"
            if [true,false].sample #if confirmed...
              user_key.time_confirmed = 1.week.ago.to_date
              # random characters for key hash
              user_key.value = Faker::Lorem.characters(10)
              user_key.status = "confirmed"
            end
          end
        end
        
        user_key.created_at = Time.now
        user_key.updated_at = Time.now        
        
        # Step 3B part 1: add between 0 to 3 comments for each submitted key
        # also add filters and orgs
        unless user_key.status == "awaiting_submission"
          Comment.populate 0..3 do |comment|
            comment.message = Faker::Hacker.say_something_smart
            # pick random approver for comment
            comment.user_key_id = user_key.id
            comment.user_id = User.approvers.to_a.sample.id
            # randomize if true or false
            comment.is_private = [true,false]
            # random time in the past, up to 30 days in past
            comment.time_posted = 10.days.ago.to_date
            # set the timestamps
            comment.created_at = Time.now
            comment.updated_at = Time.now
          end
          UserKeyFilter.populate 1..3 do |user_key_filter|
            user_key_filter.user_key_id = user_key.id 
            user_key_filter.filter_id = Filter.all.to_a.sample.id
            # set the timestamps
            user_key_filter.created_at = Time.now
            user_key_filter.updated_at = Time.now
          end
          UserKeyOrganization.populate 1..3 do |user_key_organization|
            user_key_organization.user_key_id = user_key.id 
            user_key_organization.organization_id = Organization.all.to_a.sample.id
            # set the timestamps
            user_key_organization.created_at = Time.now
            user_key_organization.updated_at = Time.now
          end
        end
        
        # Step 3B part 2: add approvals to keys awaiting approval
        if user_key.status == "awaiting_confirmation"
          Approval.populate 1..3 do |approval| #always less than 4 approvers
            approval.user_key_id = user_key.id 
            approval.user_id = User.approvers.to_a.sample.id
            # set the timestamps
            approval.created_at = Time.now
            approval.updated_at = Time.now
          end
        elsif user_key.status == "confirmed"
          #all approvers approved this key
          list_of_approvers = User.approvers.to_a
          Approval.populate User.approvers.size do |approval|
            approval.user_key_id = user_key.id
            approval.user_id = list_of_approvers.pop.id
            # set the timestamps
            approval.created_at = Time.now
            approval.updated_at = Time.now
          end
        end
      end
    end
  end
end