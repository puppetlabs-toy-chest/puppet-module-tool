require 'pathname'
require 'fileutils'

begin
  require 'puppet'
rescue LoadError
  begin
    require 'rubygems'
    require 'puppet'
  rescue LoadError
    abort "You must have Puppet installed to run PMT"
  end
end


module Puppet::Module::Tool
  ARTIFACTS = ['pkg', /^\./, /^~/, /^#/, 'coverage']

  def self.artifact?(path)
    case File.basename(path)
    when *ARTIFACTS
      true
    else
      false
    end
  end

  def self.root
    @root ||= Pathname.new(File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..')))
  end

  def self.version
    @version ||= (root + 'VERSION').read
  end

  def self.pmtdir
    @pmtdir ||=
      begin
        path = Pathname.new(Puppet.settings[:pmtdir])
        path.mkpath
        path
      end
  end

  def self.repository
    @repository ||= Repository.new(Puppet.settings[:repository])
  end

  FULL_NAME_PATTERN = /\A(.+)[\/\-](.+)\z/

  # Return the +username+ and +modname+ for a given +full_name+, or raise an
  # ArgumentError if the argument isn't parseable.
  def self.username_and_modname_from(full_name)
    if matcher = full_name.match(FULL_NAME_PATTERN)
      return matcher.captures
    else
      raise ArgumentError, "Not a valid full name: #{full_name}"
    end
  end

end

# Add vendored code to $LOAD_PATH
Dir[Puppet::Module::Tool.root + 'vendor/*/lib'].each do |path|
  $LOAD_PATH.unshift(path)
end

# Load vendored libraries
require 'versionomy'

# Add support for Puppet's settings file
require 'puppet/module/tool/utils'
module Puppet::Module::Tool
  extend Utils::Settings
end

# Add remaining libraries
require 'puppet/module/tool/applications'
require 'puppet/module/tool/cache'
require 'puppet/module/tool/checksums'
require 'puppet/module/tool/cli'
require 'puppet/module/tool/contents_description'
require 'puppet/module/tool/dependency'
require 'puppet/module/tool/metadata'
require 'puppet/module/tool/modulefile'
require 'puppet/module/tool/repository'
require 'puppet/module/tool/skeleton'
