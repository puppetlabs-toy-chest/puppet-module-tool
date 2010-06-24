# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  # Return paragraph describing the number of +named+ (e.g. "module") items in
  # a +collection+. The +collection+ can also be the number to use for the count.
  def count(name, collection)
    number =
      if collection.kind_of?(Numeric)
        collection
      elsif collection.respond_to?(:count)
        collection.count
      else
        raise TypeError, "Unknown collection type: #{collection.class.name}"
      end
      
    if number == 0
      return(content_tag :p, "No #{h(name).pluralize} found.", :class => 'blank')
    else
      return(content_tag :p, "#{pluralize number, h(name)} found.")
    end
  end

  # Return clickable list of tags for the +taggable+ record with the categories expanded.
  def tag_list(taggable)
    tags = taggable.tags.map do |tag|
      name = Categories[tag] || tag
      link_to(name, tag, :title => %(Tagged "#{h tag.name}"))
    end
    return tags.join(', ')
  end

  # Explain why the anonymous or currently logged in user has privileges.
  # Returns a string like "(DEV)" or "(ADMIN)" when privileged, or nil if not.
  def privilege_label
    privileged?.tap do |value|
      case value
      when Symbol
        return "(#{value.to_s.upcase})"
      else
        return nil
      end
    end
  end
  
end
