module Categories

  extend Comparable

  def self.each(&block)
    list.each(&block)
  end
  
  def self.list
    @list ||= []
  end

  def self.category(tag, title)
    list << [title, tag]
  end

  def self.[](tag)
    tag = tag.is_a?(Tag) ? tag.name : tag
    tag = tag.to_sym
    list.each do |title, cat_tag|
      return title if tag == cat_tag
    end
    nil
  end

  # Return only category tags associated with at least one module
  def self.populated_tags
    category_tag_names = Categories.list.map(&:last).map(&:to_s)
    existing_category_tag_ids = Tag.all(:conditions => ['name in (?)', category_tag_names]).map(&:id)
    return Mod.tag_counts_on(:tags, :at_least => 1, :conditions => ["#{Tag.table_name}.id in (?)", existing_category_tag_ids])
  end

  # Return only category name pairs associated with at least one module
  def self.populated
    return self.populated_tags.map{|tag| [tag.name.to_sym, self[tag]]}
  end

  category :databases, 'Databases'
  category :webservers, 'Web Servers'
  category :processes, 'Process Management'
  category :monitoring, 'Monitoring and Trending'
  category :languages, 'Programming Languages'
  category :packaging, 'Package Management'
  category :applications, 'Applications'
  category :networking, 'Networking'
  category :os, 'Operating Systems and Virtualization'
  category :security, "Security"
  category :utilities, "Utilities"

end
