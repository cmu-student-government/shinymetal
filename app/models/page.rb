# Class to hold the content of a static page, so that admins can edit them.
class Page < ActiveRecord::Base
  # Page has no validations or relationships, because
  # only the page's content can be manipulated on the front end.

  # The content of a page is stored as Markdown, to be rendered as html by an application helper.

  # Static pages, with content to be determined by an admin.
  # Theoretically, functionality could be extended so that the admin can add pages,
  # but this would add unnecessary complexity to this app.
  PAGE_LIST = {"welcome" => "Welcome to The Bridge API",
               "contact" => "Contact Us",
               "about" => "About Us",
               "terms" => "Terms and Conditions",
               "instructions" => "Instructions for Applying"
  }

  # Class method to fetch one of the four possible Pages.
  # If the requested, valid Page does not exit, the method both creates and fetchs it.
  # The page is created with a default message that should be changed.
  #
  # @param url [String] The url for the page.
  # @return [Page, nil] The page object for that url, or nil if such page is not permitted to exist.
  def self.find_or_create(url)
    # Return nil if the page url is not permitted to exist.
    return nil unless PAGE_LIST.include?(url)
    # Create the page if it doesn't exist, or fetch it if it does.
    # Its message will be rendered with Markdown.
    return Page.find_by_url(url) ||
           Page.create(url: url,
                name: PAGE_LIST[url],
                message: "This page is blank.
                \r\n\r\n>_You can **edit** this page to add new content._")
  end
end
