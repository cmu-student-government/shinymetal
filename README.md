## The Bridge API Project
[![Build Status](https://travis-ci.org/cmu-student-government/shinymetal.svg?branch=master)](https://travis-ci.org/cmu-student-government/shinymetal) [![Code Climate](https://codeclimate.com/github/cmu-student-government/shinymetal/badges/gpa.svg)](https://codeclimate.com/github/cmu-student-government/shinymetal) [![Test Coverage](https://codeclimate.com/github/cmu-student-government/shinymetal/badges/coverage.svg)](https://codeclimate.com/github/cmu-student-government/shinymetal)

*Developed by the Shiny Metal Team for 67-373, Spring 2015.*

This app is for Carnegie Mellon University use. Users login through CMU's Shibboleth.
Non-CMU users will be unable to login.

Requires use with **Ruby 2.0**. Has documentation generated using the YARD gem.
To run this app, migrate with **rake db:migrate** and populate with **rake db:populate** to
get an **admin** user, some approvers, some requesters, and test data for their keys.


## Setup by Admin

Before the application can be useful, an administrator must fill in the content of the "static" pages
(optionally using Markdown shortcuts to format the text more nicely).

Admins must also create questions in the settings page, add filters to the system, populate Organization
data, populate Filter data, and promote users to Staff (Approver) or Staff as needed.


## User Key Status Logic

There are two parts to this app: the front-end key application processing, and the API.

For the first part, this application provides functionality for requesting keys, which can be used to access
restricted data from the Bridge. A key application may be at one of five stages:

**Awaiting_submission**: The request for a key has been started by a user. The user fills in the key's name,
text boxes describing the project that the key will be used for, and agrees to terms of use.
At this stage, the request is only visible to its requester. The requester can save their progress,
and decides when to submit the key. (A key that has been *reset* is sent back to this stage, with public comments
intact, to tell the user what needs to be changed.)

**Awaiting_filters**: Once the key is submitted, admins and staffmembers can see the key. Only admins can
assign filter and organization access to the key. At this step and after this step, admins and staffmembers
can comment on the key. The admin assigns rights by reading the request and deciding what access rights are
appropriate. The exact filters that a key is assigned are not made public or shown to the requester (for
security purposes, and so the requester doesn't have to learn the logic of the system) until, and if,
they get those rights later (so they know what filters they should use for the API).
The admin also sets the expiration date at this time. Any comments made are visible only to staffmembers,
except for admin comments that are marked as public, which can also be read by the requester. Admins
can delete comments at any time.

Administrators need to add filters to the system manually, since it is not clear to the development
team what filter values will be needed.
Columns and Organizations can be populated automatically via the settings page by admins
(there is a settings icon in the navigation bar for staff). Organization names, tied to external ids,
must be stored in the system so that admins can assign organization access by name.

This step and its progress are invisible to the requester.

**Awaiting_confirmation**: Once the admin is done assigning rights, the request can be opened up for approval.
All admins, and all staffmembers who are also designated as approvers, can approve the key at this step.
Once all approvers in the system have approved the key, the admin can confirm the key and release it
to the requester. This step and its progress are invisible to the requester.

The "approve key" button is intentionally at the bottom of the Permissions panel so that approvers are encouraged
to read the permission data.

**Confirmed**: All staffmembers as well as the requester can now see the key's value and confirmed status.
The key's owner and the staff can all see the access rights that the key has.
The admin can continue to make changes to the key. At any step, the admin can suspend a key by
inactivating it. The key's owner and staff can continue to look at inactive keys.

*Expired*: The expiration date has passed. The key may have any status, but if it has a passed expiration date,
it is considered to be expired. The key is still active but can no longer get a
valid value. The key cannot be renewed; a new key must be requested.


## Deployment Notes

Security for this application follows Kerckhoffs's principle; the implementation details, but not the keys, are available
to the public.

To deploy this app:
+ Ensure that you have a `settings.yml` with the correct private info uploaded to your target server, and located under `<APP_DIRECTORY>/shared/config/`.
+ Ensure that settings.yml is in your gitignore, and not commited. If it does end up getting commited, reset all keys and private data inside it and ignore before moving forward.
+ use `capistrano staging|production deploy` to run the deploy script

Depending on server access, you may have to manually update the crontab on your user account, use the following crontab as guidance:

```bash
PATH=/usr/bin:/bin:/usr/local/bin

0 0 * * * /bin/bash -l -c 'cd /path/to/app/bridgeapi/current && RAILS_ENV=staging bundle exec rake email:expiry_warning --silent'

0 0 * * * /bin/bash -l -c 'cd /path/to/app/bridgeapi/current && RAILS_ENV=staging bundle exec rake email:expired --silent'

0 0 1,8,15,22 * * /bin/bash -l -c 'cd /path/to/app/current && RAILS_ENV=staging bundle exec rake repopulate:orgs --silent'

0 0 1 * * /bin/bash -l -c 'cd /path/to/app/current && RAILS_ENV=staging bundle exec rake repopulate:columns --silent'
```



TODO
====
* Crontab needs to be manually updated currently every time we change cronjobs, and should be on the apache user
* Crontab is also not being updated on cap deploys
* Fill in deployment notes for future teams
