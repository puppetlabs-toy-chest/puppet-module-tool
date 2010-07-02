# To change this template, choose Tools | Templates
# and open the template in the editor.

module MarukuHelper
  # List of HTML tags allowed in #markdown.
  ALLOWED_TAGS = %w[a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p pre code]

  # List of HTML tag attributes allowed in #markdown.
  ALLOWED_ATTRIBUTES = %w[href title]

  # Return sanitized HTML produced by parsing the +text+ through Maruku, a Markdown parser.
  def markdown(text)
    if text.blank?
      return nil
    else
      return content_tag(:div, :class => "markeddown") do
        sanitize(
          Maruku.new(Hpricot.parse(text).to_s).to_html,
          :tags => ALLOWED_TAGS,
          :attributes => ALLOWED_ATTRIBUTES
        )
      end
    end
  end
end
