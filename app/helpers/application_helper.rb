# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  # Return paragraph describing the number of +named+ (e.g. "module") items in a +collection+.
  def count(name, collection)
    method = collection.respond_to?(:count) ? :count : :size
    number = collection.send(method)
    if number == 0
      return content_tag :p, "No #{h(name).pluralize} found.", :class => 'blank'
    else
      return content_tag :p, "#{pluralize number, h(name)} found."
    end
  end

  # Return clickable list of tags for the +taggable+ record with the categories expanded.
  def tag_list(taggable)
    tags = taggable.tags.map do |tag|
      name = Categories[tag] || tag
      link_to name, tag, :title => %(Tagged "#{h tag.name}")
    end
    return tags.join(', ')
  end
  
end
