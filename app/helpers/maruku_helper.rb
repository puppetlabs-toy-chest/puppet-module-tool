# To change this template, choose Tools | Templates
# and open the template in the editor.

module MarukuHelper
  # Replacement for Rails' default Markdown helper which uses Maruku instead
  # of BlueCloth.
  def markdown(text)
    text.blank? ? "" : Maruku.new(text).to_html
  end
end
