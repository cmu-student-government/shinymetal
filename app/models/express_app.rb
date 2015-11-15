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

end
