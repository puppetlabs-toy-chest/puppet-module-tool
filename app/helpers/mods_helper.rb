module ModsHelper

  def project_feed_link(mod)
    unless mod.project_feed_url.blank?
      type = %w(atom rss).detect { |t| mod.project_feed_url.include?(t) }
      auto_discovery_link_tag(type.to_sym, mod.project_feed_url, :title => "#{mod.full_name} Puppet Module Project Feed")
    end
  end
  
end
