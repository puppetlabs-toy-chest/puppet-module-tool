class ReleaseQuery

  def initialize(mod, version_requirement = nil)
    @mod = mod
    @version_requirement = VersionRequirement.parse(version_requirement)
  end

  def execute
    if @version_requirement
      @mod.releases.ordered.detect do |release|
        @version_requirement.satisfied_by?(release.version)
      end
    else
      @mod.releases.ordered.first
    end
  end

  class VersionRequirement

    MATCHERS = ['==', '>', '<', '>=', '<=']
    MATCHER_PATTERN = MATCHERS.map { |m| Regexp.quote(m) }.join('|')
    PATTERN = /^(=|#{MATCHER_PATTERN})?\s*(\d.*?)$/o
    EQUALS = [nil, '=']

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

    def satisfied_by?(candidate)
      v = parsed(candidate)
      v.send(@matcher, @version)
    end

    private

    def parsed(raw)
      Versionomy.parse(raw)
    end
    
  end

end
