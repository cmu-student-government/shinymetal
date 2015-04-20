class Page < ActiveRecord::Base
  # No validations or relationships, because
  # only the page's content can be manipulated on the front end.
  
  # The content of a page is stored as Markdown, to be rendered as html by an application helper.
  
  # Static pages, with content to be determined by an admin.
  # Theoretically, functionality could be extended so that the admin can add pages,
  # but this would add unnecessary complexity to the app.
  PAGE_LIST = {"welcome" => "Welcome to the Bridge API",
               "contact" => "Contact Us",
               "about" => "About Us",
               "terms" => "Terms and Conditions"
  }
  
  # Method to fetch one of the four possible Pages.
  # If the requested, valid Page does not exit, the method both creates and fetchs it.
  def self.find_or_create(url)
    return nil unless PAGE_LIST.include?(url)
    return Page.find_by_url(url) ||
           Page.create(url: url,
                name: PAGE_LIST[url],
                message: "This page is blank.
                \r\n\r\n>_You can **edit** this page to add new content._")
  end
end
