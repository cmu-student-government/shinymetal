namespace :db do
  # Populate file and structure taken from PATS
  # First, this populate destroys everything in the database
  # Second, this creates some filters, orgs, and users who are approvers
  # Third, this creates normal users, their keys, their key's rights,
  # their's keys comments, and their keys approvals if applicable

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
    [Approval, Comment, Filter, Organization, WhitelistFilter, Whitelist, UserKeyOrganization, User, UserKey, Column, UserKeyColumn].each(&:delete_all)

    # Step 2: Add Filters, Orgs, and Approvers
    # Define resources, filter_names, filter_values
    filter_lists = [["organizations","type","closed"],
                 ["organizations","type","somewhat closed"],
                 ["events","currentEventsOnly","true"],
                 ["events","currentEventsOnly","somewhat true"],
                 ["attendees","status","active"],
                 ["attendees","status","somewhat active"],
                 ["memberships","currentMembershipsOnly","true"],
                 ["memberships","currentMembershipsOnly","somewhat true"],
                 ["positions","type","public"],
                 ["positions","type","somewhat public"],
                 ["users","status","active"],
                 ["users","status","somewhat active"]]
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
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.andrew_id = "#{user.first_name[0] + user.last_name}"
      user.role = "staff_approver"
      user.active = true
      # save with bang (!) so exception is thrown on failure
      user.save!
    end

    # and admin user
    admin_user = User.new
    admin_user.first_name = Faker::Name.first_name
    admin_user.last_name = Faker::Name.last_name
    admin_user.andrew_id = "admin"
    admin_user.role = "admin"
    admin_user.active = true
    admin_user.save!

    # Step 3: add 20 requesters
    User.populate 20 do |user|
      # each key needs a role, active, and andrew_id
      # get some fake data using the Faker gem
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.andrew_id = "#{user.first_name[0] + user.last_name}"
      user.active = true
      user.role = "requester"
      # set the timestamps
      user.created_at = Time.now
      user.updated_at = Time.now

      # Step 3A: add 0 to 3 keys for each requester
      UserKey.populate 0..3 do |user_key|
        user_key.user_id = user.id
        user_key.name = Faker::Company.name
        user_key.agree = true
        # I tried to DRY this, but Populator gem wouldn't let me
        user_key.proposal_text_one = Faker::Lorem.paragraph
        user_key.proposal_text_two = Faker::Lorem.paragraph
        user_key.proposal_text_three = Faker::Lorem.paragraph
        user_key.proposal_text_four = Faker::Lorem.paragraph
        user_key.proposal_text_five = Faker::Lorem.paragraph
        user_key.proposal_text_six = Faker::Lorem.paragraph
        user_key.proposal_text_seven = Faker::Lorem.paragraph
        user_key.proposal_text_eight = [Faker::Lorem.paragraph, nil]

        # make sure all begin as awaiting submission
        user_key.status = "awaiting_submission"
        # now begin submitting some keys randomly
        if [true,false].sample #50 percent change if this key was submitted....
          user_key.time_submitted = 3.weeks.ago.to_date
          user_key.status = "awaiting_filters"

          if [true,false].sample # if filters applied...
            user_key.time_filtered = 2.weeks.ago.to_date

            # time_expired is randomly 1..3 months from now, or 1..2 months ago
            user_key.time_expired = (1..5).map{|d| d.months.from_now}.append((1..2).map{ |d| d.months.ago})

            user_key.status = "awaiting_confirmation"
            if [true,false].sample # if the key was confirmed...
              user_key.time_confirmed = 1.week.ago.to_date
              # Set a random name for the key
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
            comment.user_id = User.approvers_only.to_a.sample.id
            comment.public = false
            # set the random timestamps
            comment.created_at = (1..10).map{|num| num.days.ago.to_date}
            comment.updated_at = Time.now
          end
          # Admin comments
          Comment.populate 0..2 do |comment|
            comment.message = Faker::Hacker.say_something_smart
            comment.user_key_id = user_key.id
            comment.user_id = admin_user.id
            # randomize if true or false
            comment.public = [true,false]
            # set the random timestamps
            comment.created_at = (1..10).map{|num| num.days.ago.to_date}
            comment.updated_at = Time.now
          end
          # Create 1 to 3 whitelists for each key, each a different resource
          resource_list = Resource::RESOURCE_LIST.shuffle
          Whitelist.populate 1..3 do |whitelist|
             whitelist.user_key_id = user_key.id
             # Make it one of the resources
             whitelist.created_at = Time.now
             whitelist.updated_at = Time.now
             # get a list of filters to avoid repeat filters being assigned to a single whitelist
             filter_list = Filter.restrict_to(resource_list.pop).to_a.shuffle
             WhitelistFilter.populate 1..2 do |whitelist_filter|
               whitelist_filter.whitelist_id = whitelist.id
               whitelist_filter.filter_id = filter_list.pop
               # set the timestamps
               whitelist_filter.created_at = Time.now
               whitelist_filter.updated_at = Time.now
             end
          end
          # get a list of orgs to avoid repeat orgs being assigned
          org_list = Organization.all.to_a.shuffle
          UserKeyOrganization.populate 1..3 do |user_key_organization|
            user_key_organization.user_key_id = user_key.id
            user_key_organization.organization_id = org_list.pop.id
            # set the timestamps
            user_key_organization.created_at = Time.now
            user_key_organization.updated_at = Time.now
          end
          # get a list of columns to avoid repeat columns being assigned
          # Don't populate user_key_columns;
          # doing so would requiring Column.populate, which hits the Bridge 8 times.
          # this is necessary for testing purposes
          column_list = Column.all.to_a.shuffle
          UserKeyColumn.populate 3..10 do |user_key_column|
            user_key_column.user_key_id = user_key.id
            user_key_column.column_id = column_list.pop.id
            user_key_column.created_at = Time.now
            user_key_column.updated_at = Time.now
          end
        end

        list_of_approvers = User.approvers_only.to_a
        # Step 3B part 2: add approvals to keys awaiting approval
        if user_key.status == "awaiting_confirmation"
          Approval.populate 3..6 do |approval|
            approval.user_key_id = user_key.id
            approval.user_id = list_of_approvers.pop.id
            # set the timestamps
            approval.created_at = Time.now
            approval.updated_at = Time.now
          end
        elsif user_key.status == "confirmed"
          #all approvers need to have approved this key
          Approval.populate list_of_approvers.size do |approval|
            approval.user_key_id = user_key.id
            approval.user_id = list_of_approvers.pop.id
            # set the timestamps
            approval.created_at = (1..5).map{|num| num.days.ago.to_date}
            approval.updated_at = Time.now
          end
        end
      end
    end
  end
end
