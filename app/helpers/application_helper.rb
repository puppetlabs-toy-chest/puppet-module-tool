# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  # Return paragraph containing the name of the resource and the number found.
  def count(name, collection)
    method = collection.respond_to?(:count) ? :count : :size
    count = collection.send(method)
    if count == 0
      content_tag :p, "No #{name.pluralize} found.", :class => 'blank'
    else
      content_tag :p, "#{pluralize count, name} found."
    end
  end

  # Return clickable list of tags with the categories expanded.
  def tag_list(taggable)
    tags = taggable.tags.map do |tag|
      name = Categories[tag] || tag
      link_to name, tag, :title => %(Tagged "#{tag.name}")
    end
    tags.join(', ')
  end
  
end
