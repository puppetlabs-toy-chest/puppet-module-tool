$LOAD_PATH << File.join(File.dirname(__FILE__), 'tasks')

Dir['tasks/**/*.rake'].each { |t| load t }

require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'fileutils'
require 'ftools' if RUBY_VERSION =~ /^1.8/

# Return filename matching an array of glob patterns, minus any ephemeral files
# that don't belong in the gem.
def sanitized_file_list(*args)
  return FileList[*args].reject{|filename| filename =~ /\.(~|swp|tmp)\z/}
end

GEM_FILES = sanitized_file_list [
    'CHANGES.markdown',
    'LICENSE',
    'README.markdown',
    'Rakefile',
    'VERSION',
    'bin/**/*',
    'lib/**/*',
    'templates/**/*',
    'vendor/**/*'
]

gemspec = Gem::Specification.new do |gemspec|
    gemspec.name = 'puppet-module'
    gemspec.files = GEM_FILES.to_a
    gemspec.executables = ['puppet-module']
    gemspec.version = File.read('VERSION')
    gemspec.date = File.new('VERSION').mtime
    gemspec.summary = 'The Puppet Module Tool manages Puppet modules'
    gemspec.description = 'The Puppet Module Tool creates, installs and searches for Puppet modules.'
    gemspec.author = 'Igal Koshevoy'
    gemspec.email = 'igal@pragmaticraft.com'
    gemspec.homepage = 'http://github.com/puppetlabs/puppet-module-tool'
    gemspec.rdoc_options = ['--main', 'README.rdoc']
    gemspec.require_paths = ['lib']
    gemspec.test_files = sanitized_file_list ['spec/**/*']
    gemspec.post_install_message = <<-POST_INSTALL_MESSAGE
#{'*'*78}

  Thank you for installing puppet-module from Puppet Labs!

  * Usage instructions: read "README.markdown" or run `puppet-module usage`
  * Changelog: read "CHANGES.markdown" or run `puppet-module changelog`
  * Puppet Forge: visit http://forge.puppetlabs.com/
  * If you don't have Puppet installed locally by your system package
    manager, please install it with:

        sudo gem install puppet


#{'*'*78}
    POST_INSTALL_MESSAGE
end

Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  task :spec do
    puts 'ERROR! RSpec not found, install it by running: sudo gem install rspec'
  end
end

task :default => :spec

# Aliases for rvm
task :specs => :spec
task :tests => :spec
task :test => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
    version = File.read('VERSION')

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "puppet-modules #{version}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
end
