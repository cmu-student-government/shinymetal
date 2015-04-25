# Sets default "from" email address and mailer layout for all emails.
class ApplicationMailer < ActionMailer::Base
  default from: "noreply-stugov@andrew.cmu.edu"
  layout 'mailer'
end
