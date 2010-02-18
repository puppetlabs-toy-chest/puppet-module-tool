module ReleasesHelper

  def guess_next_version
    if @release.new_record?
      current = @mod.releases.current
      return current.guess_next_version if current
    end
    nil
  end

  
end
