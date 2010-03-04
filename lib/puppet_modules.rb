require 'pathname'
require 'fileutils'

module PuppetModules

  autoload :CLI,                 'puppet_modules/cli'
  autoload :Applications,        'puppet_modules/applications'
  autoload :Cache,               'puppet_modules/cache'
  autoload :Commands,            'puppet_modules/commands'
  autoload :ContentsDescription, 'puppet_modules/contents_description'
  autoload :Dependency,          'puppet_modules/dependency'
  autoload :Metadata,            'puppet_modules/metadata'
  autoload :Modulefile,          'puppet_modules/modulefile'
  autoload :Repository,          'puppet_modules/repository'
  autoload :Skeleton,            'puppet_modules/skeleton'
  autoload :Utils,               'puppet_modules/utils'

  def self.root
    @root ||= Pathname.new(__FILE__).parent + '..'
  end

  def self.version
    @version ||= (root + 'VERSION').read
  end

  def self.repository
    @repository ||= Repository.new
  end
  
  def self.repository=(url)
    @repository = Repository.new(url)
  end

  def self.dotdir
    @dotdir ||=
      begin
        path = Pathname.new(ENV['HOME']) + '.puppet-modules'
        path.mkpath
        path
      end
  end

end

# Add vendored code to $LOAD_PATH
Dir[PuppetModules.root + 'vendor/*/lib'].each do |path|
  $LOAD_PATH.unshift(path)
end

