# Load standard libraries
require 'pathname'
require 'fileutils'

# Define tool
module Puppet
  class Module
    module Tool
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
      def self.working_dir
        @working_dir ||= Pathname.new(Puppet.settings[:puppet_module_working_dir])
      end

      # Return Repository to fetch data from based on Puppet's config file.
      def self.repository
        @repository ||= Repository.new(Puppet.settings[:puppet_module_repository])
      end

      FULL_NAME_PATTERN = /\A([^-\/|.]+)[-|\/](.+)\z/

      # Return the +username+ and +modname+ for a given +full_name+, or raise an
      # ArgumentError if the argument isn't parseable.
      def self.username_and_modname_from(full_name)
        if matcher = full_name.match(FULL_NAME_PATTERN)
          return matcher.captures
        else
          raise ArgumentError, "Not a valid full name: #{full_name}"
        end
      end

      # Return the filename with the usage documenation.
      def self.usage_filename
        return File.expand_path(File.join(self.root, 'README.markdown'))
      end

      # Return the filename with the changelog.
      def self.changelog_filename
        return File.expand_path(File.join(self.root, 'CHANGES.markdown'))
      end
    end
  end
end

# Add vendored code paths to $LOAD_PATH
Dir[Puppet::Module::Tool.root + 'vendor/*/lib'].each do |path|
  $LOAD_PATH.unshift(path)
end

# Load vendored libraries
require 'facets/kernel/tap'
require 'facets/kernel/returning'

# Load rubygems, so we can load Puppet and parse version numbers
require 'rubygems'

# Load Puppet
begin
  minimum_version = Gem::Version.new("0.25.0")
  message = "You must have Puppet #{minimum_version} or greater installed"

  begin
    require 'puppet'
  rescue LoadError
    abort message
  end

  begin
    current_version = Gem::Version.new(Puppet.version)
  rescue
    abort "#{message} -- couldn't parse version"
  end

  if current_version <= minimum_version
    abort "#{message} -- you're running #{current_version}"
  end
end

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
