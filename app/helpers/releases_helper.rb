module ReleasesHelper

  include MarukuHelper

  # Return string a guess of the next version of this module, else nil.
  def guess_next_version
    return @mod.releases.current.try(:guess_next_version)
  end

  # Return link to release's +dependency+.
  #
  # Options:
  # * :name => Combined name of the user and module (e.g. "myuser-mymodule"). Required.
  # * :repository => Base URL of the repository this module is at. Optional.
  def link_to_dependency(dep)
    if dep.kind_of?(Hash)
      dep = dep.symbolize_keys
      if dep[:name].present?
        if matcher = dep[:name].match(%r{\A([^-/]+)[-/]([^-/]+)\z})
          username, modname = matcher.captures
          fullname = [username, modname].join('/')
          url = nil
          if dep[:repository].present?
            url = "#{dep[:repository]}"
            url << '/' unless url[/(.)$/, 1] == '/'
            url << fullname
          else
            url = "/#{fullname}"
          end
          return link_to(h(fullname), url)
        end
      end
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
