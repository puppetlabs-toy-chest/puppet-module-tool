require 'pathname'
require 'fileutils'

begin
  require 'puppet'
rescue LoadError
  abort "You must have Puppet installed to run PMT"
end

require 'versionomy'

module Puppet::Module::Tool

  autoload :CLI,                 'puppet/module/tool/cli'
  autoload :Applications,        'puppet/module/tool/applications'
  autoload :Cache,               'puppet/module/tool/cache'
  autoload :Checksums,           'puppet/module/tool/checksums'
  autoload :ContentsDescription, 'puppet/module/tool/contents_description'
  autoload :Dependency,          'puppet/module/tool/dependency'
  autoload :Metadata,            'puppet/module/tool/metadata'
  autoload :Modulefile,          'puppet/module/tool/modulefile'
  autoload :Repository,          'puppet/module/tool/repository'
  autoload :Skeleton,            'puppet/module/tool/skeleton'
  autoload :Utils,               'puppet/module/tool/utils'

  ARTIFACTS = ['pkg', /^\./, /^~/, /^#/, 'coverage']

  extend Utils::Settings

  def self.artifact?(path)
    case File.basename(path)
    when *ARTIFACTS
      true
    else
      false
    end
  end

  def self.root
    @root ||= Pathname.new(__FILE__).parent + '..'
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

end

# Add vendored code to $LOAD_PATH
Dir[Puppet::Module::Tool.root + 'vendor/*/lib'].each do |path|
  $LOAD_PATH.unshift(path)
end
