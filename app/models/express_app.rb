# A user key may be requested through an express application
# If it is, the info about that express app will reside here
class ExpressApp < ActiveRecord::Base
  belongs_to :user_key

  WHITELIST_COLUMNS = {
    events: %w(eventId name shortName description organizationId organizationName startDateTime endDateTime addressStreet1 addressStreet2 addressCity otherLocation eventUrl flyerUrl thumbnailUrl),
    organizations: %w(organizationId name shortName summary description email externalWebsite facebookUrl twitterUrl flickrFeedUrl youtubeChannelUrl googleCalendarUrl profileImageUrl profileUrl primaryContactName primaryContactCampusEmail)
  }

  WHITELIST_FILTERS = {
    # [filter_name, filter_value]
    events: [["status", "*"], ["category", "*"], ["name", "*"], ["currentEventsOnly", "true,false"], ["startDate", "*"], ["endDate", "*"], ["type", "Public,Campus Only"]],
    organizations: [["status", "*"], ["category", "*"], ["name", "*"], ["excludeHiddenOrganizations", "true"]]
  }
end
