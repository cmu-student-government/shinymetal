module ApplicationHelper
  # This method is called on markdown text, output as html
  def markdown(text)
    markdown = Redcarpet::Markdown.new(
    Redcarpet::Render::HTML.new(
      :filter_html => true,
      :no_links => true,
      :safe_links_only => true,
      :hard_wrap => true),
    :autolink => true,
    :no_intraemphasis => true, 
    :fenced_code => true)
    markdown.render(text).html_safe
  end
end
