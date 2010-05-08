module ReleasesHelper

  # Return string a guess of the next version of this module, else nil.
  def guess_next_version
    return @mod.releases.current.try(:guess_next_version)
  end

  # Return link to release's +dependency+, a hash containing a 'name'.
  def link_to_dependency(dep)
    if dep.kind_of?(Hash) && dep.has_key?('name')
      # NOTE: This generates a raw vanity URL
      return(link_to(h(dep['name']), "/#{dep['name']}"))
    end
  end
  
end
