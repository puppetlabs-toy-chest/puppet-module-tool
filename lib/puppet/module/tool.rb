# Load standard libraries
require 'pathname'
require 'fileutils'

# Load Puppet
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

# Define tool
module Puppet::Module::Tool
  # Default repository URL.
  REPOSITORY_URL = 'http://forge.puppetlabs.com'

  # Directory names that should not be checksummed.
  ARTIFACTS = ['pkg', /^\./, /^~/, /^#/, 'coverage']

  # Is this a directory that shouldn't be checksummed?
  #
  # TODO: Should this be part of Checksums?
  # TODO: Rename this method to reflect it's purpose?
  # TODO: Shouldn't this be used when building packages too?
  def self.artifact?(path)
    case File.basename(path)
    when *ARTIFACTS
      true
    else
      false
    end
  end

  # Return Pathname for the directory this tool was installed into.
  def self.root
    @root ||= Pathname.new(File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..')))
  end

  # Return the tool's string version.
  def self.version
    @version ||= (root + 'VERSION').read
  end

  # Return Pathname for this tool's working directory.
  def self.pmtdir
    @pmtdir ||= Pathname.new(Puppet.settings[:pmtdir])
  end

  # Return Repository to fetch data from based on Puppet's config file.
  def self.repository
    @repository ||= Repository.new(Puppet.settings[:modulerepository])
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

# Add vendored code paths to $LOAD_PATH
Dir[Puppet::Module::Tool.root + 'vendor/*/lib'].each do |path|
  $LOAD_PATH.unshift(path)
end

# Load vendored libraries
require 'versionomy'
require 'facets/kernel/tap'
require 'facets/kernel/returning'

# Add support for Puppet's settings file
require 'puppet/module/tool/utils'
module Puppet::Module::Tool
  extend Utils::Settings
end

# Load remaining libraries
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
