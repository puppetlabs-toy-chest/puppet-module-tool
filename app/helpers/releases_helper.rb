module ReleasesHelper

  include MarukuHelper

  # Return string a guess of the next version of this module, else nil.
  def guess_next_version
    return @mod.current_release.try(:guess_next_version)
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
  # Arguments:
  # * element: Required hash containing:
  #   * :name => Name of the property, parameter or provider.
  #   * :doc => Docuentation about the property, parameter or provider as Markdown.
  # * html: Optional hash containing any HTML options to pass to the #content_tag, e.g. :class.
  def label_doc(element, html={})
    if element.kind_of?(Hash)
      element = element.symbolize_keys
      name = element[:name]
      doc  = element[:doc]

      return "" unless name

      content_tag :dl, html do
        [content_tag(:dt, name),
        content_tag(:dd, markdown(doc))]
      end
    end
  end

end
