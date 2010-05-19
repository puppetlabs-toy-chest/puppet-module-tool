class ReleaseQuery

  def initialize(mod, version_requirement = nil)
    @mod = mod
    @version_requirement = VersionRequirement.parse(version_requirement)
  end

  # Returns the most recent release of +@mod+ matching the optional
  # +@version_requirement+
  def execute
    if @mod
      scope = @mod.releases.ordered
      if scope.any?
        if @version_requirement
          return scope.detect do |release|
            @version_requirement.satisfied_by?(release.version)
          end
        else
          return scope.first
        end
      else
        # No matching releases
        return nil
      end
    else
      # No such mod
      return nil
    end
  end

  # The version requirement for a release; a version number and a
  # comparison to match against.
  class VersionRequirement

    MATCHERS = ['==', '>', '<', '>=', '<=']
    MATCHER_PATTERN = MATCHERS.map { |m| Regexp.quote(m) }.join('|')
    PATTERN = /^(=|#{MATCHER_PATTERN})?\s*(\d.*?)$/o
    EQUALS = [nil, '=']

    # Parse a version requirement
    # call-seq:
    #   parse('>= 1.1.0')
    def self.parse(text)
      return unless text
      match = text.match(PATTERN)
      matcher, version = match[1, 2]
      matcher = '==' if EQUALS.include?(matcher)
      new(matcher, version)
    end

    def initialize(matcher, version)
      @matcher = matcher
      @version = parsed(version)
    end

    # Check a version number to see if it satisfies the requirement
    # call-seq:
    #   satisfied_by?('1.1.1')
    def satisfied_by?(candidate)
      v = parsed(candidate)
      v.send(@matcher, @version)
    end

    private

    # Use Versionomy to parse the version number for comparison
    def parsed(raw)
      return raw if raw.is_a?(Versionomy::Value)
      Versionomy.parse(raw)
    end
    
  end

end
