module ReleasesHelper

  include MarukuHelper

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

  # Return HTML with name and documentation for a Puppet property, parameter or provider. 
  #
  # Options:
  # * :name => Name of the property, parameter or provider.
  # * :doc => Docuentation about the property, parameter or provider as Markdown.
  def label_doc(opts)
    if opts.kind_of?(Hash)
      opts = opts.symbolize_keys
      html = ""
      has_name = opts[:name].present?
      has_doc  = opts[:doc].present?
      if has_name
        html << "<b>#{h(opts[:name]) + (has_doc ? ':&nbsp' : '')}</b>"
      end
      if has_doc
        html << markdown(opts[:doc])
      end
      return html
    end
  end
  
end
