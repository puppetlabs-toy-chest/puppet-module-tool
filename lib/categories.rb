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
