Bite My Shiny Metal API Project for 67-373 Spring 2015.

Still in development.

To run, migrate with **rake db:migrate** and populate with **rake db:populate** to get an **admin** user, some approvers, some requesters, and data for their keys.

**Note to team:** For any comments that need to be returned to later, mark with **FIXME** so we can find them.

This application provides functionality for requesting application keys. A key may be at one of five stages:

*Awaiting_submission*: The request for a key has been started by a user. The user fills in the key's name,
8 text boxes describing the project that the key will be used for, and agrees to terms of use.
At this stage, the request is only visible to its requester. The requester can save their progress,
and decides when to submit the key. (A key that has been *reset* is sent back to this stage, with comments
intact, to tell the user what needs to be changed.)

*Awaiting_filters*: Once the key is submitted, admins and staffmembers can see the key. Only admins can
assign filter and organization access to the key. At this step and after this step, admins and staffmembers
can comment on the key. The admin assigns rights by reading the request and deciding what access rights are
appropriate. The exact filters that a key is assigned are never made public or shown to the requester (for
security purposes, and so the requester doesn't have to learn the logic of the system).
The admin also sets the expiration date at this time. All comments are visible only to staffmembers,
except for admin comments that are marked as public, which can also be read by the requester.
This step and its progress are invisible to the requester.

*Awaiting_confirmation*: Once the admin is done assigning rights, the request is opened up for approval.
All admins, and all staffmembers who are also designated as approvers, can approve the key at this step.
Once all approvers in the system have approved the key, the admin must confirm the key and release it
to the requester. This step and its progress are invisible to the requester.

*Confirmed*: All staffmembers as well as the requester can now see the key's value and confirmed status.
The admin can continue to make changes to the key. At any step, the admin can suspend a key by inactivating
it. Staff can continue to look at it.

*Expired*: The expiration date has passed. The key is still active but can no longer get a
valid value. The key cannot be renewed; a new key must be requested.


TODO
====
* Crontab needs to be manually updated currently every time we change cronjobs, and should be on the apache user
* Crontab is also not being updated on cap deploys
