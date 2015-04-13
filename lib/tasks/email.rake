namespace :email do
  
  desc 'sends expiring in a month warning email'
  task expiry_warning: :environment do
    UserKey.expires_in_a_month.each do |uk|
  	  puts uk.name
  	  UserKeyMailer.expiry_warning_msg(uk.user, uk).deliver!
    end
  end

  desc 'sends your key has expired email'
  task expired: :environment do
    UserKey.expires_today.each do |uk|
  	  UserKeyMailer.expiry_msg(uk.user, uk).deliver!
    end
  end

end
