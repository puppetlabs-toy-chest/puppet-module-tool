module ReleasesHelper

  def guess_next_version
    if @release.new_record?
      current = @mod.releases.current
      return current.guess_next_version if current
    end
    nil
  end

  def label_doc(obj)
    if obj['doc'].blank?
      haml_tag :b do
        haml_concat obj['name']
      end
    else
      haml_tag :b do
        haml_concat obj['name'] + ':&nbsp;'
      end
      haml_concat obj['doc']
    end
  end

  def link_to_dependency(dep)
    link_to dep['name'], "/#{dep['name']}"
  end
  
end
