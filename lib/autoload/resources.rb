# Library for the known parameters recognized by CollegiateLink.
# Only the resources that Carnegie Mellon University uses are used here.
module Resources  
  # RESOURCE_LIST is used by both the Column and Filter models.
  # Also used in views: creating valid filters in the filter form, for list of resources in user key pages.
  # RESOURCE_LIST holds all endpoints that are available from CollegiateLink and used by CMU.
  RESOURCE_LIST = ['organizations','events','attendees','memberships','positions','users','demo_endpoint']
  
  # PARAM_NAME_HASH is to ensure that only valid filters can be created.
  # A *valid* filter is one that would be recognized by Collegiatelink API.
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
                               "enrollmentStatus","primarySchoolOfEnrollment","status"] }
                       # "page" and "pageSize" are also available params for all endpoints.
                       # However, it should not be possible to create a filter for them.
end
