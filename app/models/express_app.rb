# A user key may be requested through an express application
# If it is, the info about that express app will reside here
class ExpressApp < ActiveRecord::Base
  belongs_to :user_key


  # Define our requester types, and their humanized values
  enum requester_type: [:course, :extracurricular, :department, :organization]

  # requester_type: [humanized text, additional info question, additional info hint]
  REQUESTER_TYPES_HUMANIZED = {
    course: ["Individual (Class)", "with these additional students (Andrew IDs, if applicable)", "acarnegie, amellon"],
    extracurricular: ["Individual (Extracurricular)", "with these additional students (Andrew IDs, if applicable)", "acarnegie, amellon"],
    department: ["Professor / Department", "for the department", "Information Systems"],
    organization: ["Organization", "for the organization", "Activities Board"]
    # other: ["Other", ". Please explain", ""]
  }


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


      # TODO figure out how to get desc and examples through to view

      #   <% orgs_cols = ExpressApp::WHITELIST_COLUMNS[:organizations] %>
      #   <% events_cols = ExpressApp::WHITELIST_COLUMNS[:events] %>
      #   <table id="columns-selection-table">
      #     <thead>
      #       <tr>
      #         <th>Organizations</th>
      #         <th>Events</th>
      #       </tr>
      #     </thead>
      #     <tbody>
      #       <% [orgs_cols.count, events_cols.count].max.times do |i| %>
      #         <tr>
      #           <td><%= orgs_cols[i] %></td>
      #           <td><%= events_cols[i]  %></td>
      #         </tr>
      #       <% end %>
      #     </tbody>
      #   </table>
      # </li>

