module ModsHelper

  # FIXME Add validations to Mod to prevent users from adding invalid feeds that we then have to guess how to handle or how to alert users of problems.
  def project_feed_link(mod)
    unless mod.project_feed_url.blank?
      if match = mod.project_feed_url.match(/\b(atom|rss)\b/)
        auto_discovery_link_tag(match[1].to_sym, mod.project_feed_url, :title => "#{mod.full_name} Puppet Module Project Feed")
      end
    end
  end
  
end
