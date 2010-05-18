require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'fileutils'
require 'ftools'

GEM_FILES = FileList[
    '[A-Z]*',
    'bin/**/*',
    'lib/**/*',
    'templates/**/*',
    'vendor/**/*'
]

spec = Gem::Specification.new do |spec|
    spec.name = 'pmt'
    spec.files = GEM_FILES.to_a
    spec.executables = 'pmt'
    spec.version = File.read('VERSION')
    spec.add_dependency('puppet')
    spec.summary = 'The Puppet Module Tool manages modules in the Puppet Forge'
    spec.description = 'The Puppet Module Tool can adds, delete and manage modules in the Puppet Forge.'
    spec.author = 'Igal Koshevoy'
    spec.email = 'igal@pragmaticraft.com'
    spec.homepage = 'http://github.com/reductivelabs/puppet-module-tool'
    spec.rdoc_options = ["--main", "README.rdoc"]
    spec.require_paths = ["lib"]
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
end
