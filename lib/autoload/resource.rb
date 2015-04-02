class Resource
  RESOURCE_LIST = ['organizations','events','attendees','memberships','positions','users']
  PARAM_NAME_HASH = { organizations: ["organizationId",
                                      "excludeHiddenOrganizations",
                                      "status", "category","type","name"],
                       events: ["eventId",
                                "organizationId",
                                "locationId",
                                "externalLocationId",
                                "currentEventsOnly",
                                "status", "category","type",
                                "name", "startDate", "endDate"],
                       attendees: ["eventId",
                                   "organizationId",
                                   "attendanceId",
                                   "userId", "username",
                                   "attendanceStatus","status",
                                   "includeUnrecognizedUsers",
                                   "includeReflections",
                                   "startDate","endDate"],
                       memberships: ["membershipId",
                                     "userId","username",
                                     "organizationId",
                                     "currentMembershipsOnly",
                                     "publicPrivacyFilter",
                                     "campusPrivacyFilter",
                                     "includeReflections",
                                     "positionTemplateId",
                                     "positionTemplateName",
                                     "startDate","endDate"],
                       positions: ["positionId", "organizationId",
                                   "template","type","activeStatusOnly"],
                       users: ["userId","username","cardId","sisId","affiliation",
                               "enrollmentStatus","primarySchoolOfEnrollment","status"],
                       # These parameters are available to all endpoints
                       # Currently they are unused, just here for documentation purposes
                       all: ["page","pageSize"] }
  
  # Theoretically these could also be temporary, and taken from calls to collegiatelinkapi?
  # FIXME we need to figure out which ones are important. 
  COLUMN_NAME_HASH = { organizations: ["organizationId",
                                       "name",
                                       "status",
                                       "shortName",
                                       "summary",
                                       "description"
                                       # FIXME there are others for orgs
                                       ],
                       events: ["eventId",
                                   "eventName",
                                   "organizationId",
                                   "organizationName",
                                   "startDate",
                                   "endDate"
                                   # FIXME there are others for events
                                   ],
                       attendees: ["eventId",
                                   "eventName",
                                   "organizationId",
                                   "organizationName",
                                   "startDate",
                                   "endDate",
                                   "attendanceId",
                                   "userId"
                                   # FIXME again, what do attendees need?
                                    ],
                       memberships: ["membershipId",
                                     "organizationId",
                                     "organizationName",
                                     "organizationShortName"
                                    # FIXME there are others for mem too
                                     ],
                       positions: ["positionId",
                                   "positionName",
                                   "positionNameLocked"
                                   #FIXME others for positions too
                                   ],
                       users: ["userId",
                               "username",
                               "status",
                               "lastLogin",
                               "firstName",
                               "lastName",
                               "campusEmail",
                               "customFields"
                               ] }
                              # FIXME again, there are others for users
end
