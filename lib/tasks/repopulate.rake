namespace :repopulate do
  
  desc 'Repopulates columns from CollegiateLink API'
  task columns: :environment do
    Column.repopulate
  end

  desc 'Repopulates organizations from CollegiateLink API'
  task orgs: :environment do
    Organization.repopulate
  end

end
