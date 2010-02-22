require 'pathname'
require 'fileutils'

module PuppetModules
  
  autoload :Repository,   'puppet_modules/repository'
  autoload :Applications, 'puppet_modules/applications'
  autoload :Utils,        'puppet_modules/utils'
  autoload :Cache,        'puppet_modules/cache'
  autoload :Dependency,   'puppet_modules/dependency'
  autoload :Metadata,     'puppet_modules/metadata'
  autoload :Modulefile,   'puppet_modules/modulefile'

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

