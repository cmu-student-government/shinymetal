module ApplicationHelper
  # This method is called on markdown text, output as html
  def markdown(text)
    # Create the @markdowner object if it doesn't exist
    @markdowner ||= Redcarpet::Markdown.new(
    Redcarpet::Render::HTML.new(
      :filter_html => true,
      :no_links => true,
      :safe_links_only => true,
      :hard_wrap => true),
    :autolink => true,
    :no_intraemphasis => true, 
    :fenced_code => true)
    # Use the @markdowner object to render the html
    # Note: html_safe is not what it appears! It doesn't mean, 'Let's make this text safe.'
    # It means, 'This text is presumed to be safe to render as html, so let's render it.'
    @markdowner.render(text).html_safe
  end
end
