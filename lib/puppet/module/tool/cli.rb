begin
  require 'thor'
rescue LoadError
  abort "Requires 'thor'"
end

# = CLI
#
# This class is used by the `bin/pmt` program to dispatch actions.
class Puppet::Module::Tool::CLI < Thor
  include Thor::Actions
  
  map '-V' => :version

  class_option :config, :aliases => '-c', :default => Puppet.settings[:config], :desc => "Configuration file"
  
  def self.method_option_repository
    method_option :modulerepository, :aliases => '-r', :default => Puppet.settings[:modulerepository], :desc => "Module repository to use"
  end

  desc "version", "Show the version information for this tool"
  def version
    say Puppet::Module::Tool.version
  end

  desc "generate USERNAME-MODNAME", "Generate boilerplate for a new module"
  method_option_repository
  def generate(name)
    Puppet::Module::Tool::Applications::Generator.run(name, options)
  end

  # TODO Review whether the 'freeze' feature should be fixed or deleted.
#  desc "freeze", "Freeze the module skeleton (to customize for `generate`)"
#  def freeze
#    Puppet::Module::Tool::Applications::Freezer.run(options)
#  end

  desc "clean", "Clears module cache for all repositories"
  def clean
    Puppet::Module::Tool::Applications::Cleaner.run(options)
  end

  desc "build [PATH_TO_MODULE]", "Build a module for release"
  def build(path = nil)
    Puppet::Module::Tool::Applications::Builder.run(find_module_root(path), options)
  end

  # TODO Review whether the 'release' feature should be fixed or deleted.
#  desc "release FILENAME", "Release a module tarball (.tar.gz)"
#  method_option_repository
#  def release(filename)
#    Puppet::Module::Tool::Applications::Releaser.run(filename, options)
#  end

  # TODO Review whether the 'unrelease' feature should be fixed or deleted.
#  desc "unrelease MODULE_NAME", "Unrelease a module (eg, 'user-modname')"
#  method_option :version, :alias => :v, :required => true, :desc => "The version to unrelease"
#  method_option_repository
#  def unrelease(module_name)
#    Puppet::Module::Tool::Applications::Unreleaser.run(module_name,
#                                                       options)
#  end

  desc "install MODULE_NAME_OR_FILE [OPTIONS]", "Install a module (eg, 'user-modname') from a repository or file"
  method_option :version, :alias => :v, :desc => "Version to install (can be a requirement, eg '>= 1.0.3', defaults to latest version)"
  method_option :force, :alias => :f, :type => :boolean, :desc => "Force overwrite of existing module, if any"
  method_option_repository
  def install(name)
    Puppet::Module::Tool::Applications::Installer.run(name, options)
  end

  desc "search TERM", "Search the module repository for a module matching TERM"
  method_option_repository
  def search(term)
    Puppet::Module::Tool::Applications::Searcher.run(term, options)
  end

  # TODO Review whether the 'register' feature should be fixed or deleted.
#  desc "register MODULE_NAME", "Register a new module (eg, 'user-modname')"
#  method_option_repository
#  def register(module_name)
#    Puppet::Module::Tool::Applications::Registrar.run(module_name, options)
#  end

  desc "changes [PATH_TO_MODULE]", "Show modified files in an installed module"
  def changes(path = nil)
    Puppet::Module::Tool::Applications::Checksummer.run(find_module_root(path), options)
  end

  desc "repository", "Show currently configured repository"
  def repository
    Puppet::Module::Tool.prepare_settings(options)
    say Puppet.settings[:modulerepository]
  end

  no_tasks do
    def find_module_root(path)
      for dir in [path, Dir.pwd].compact
        if File.exist?(File.join(dir, 'Modulefile'))
          return dir
        end
      end
      abort "Could not find a valid module at #{path ? path.inspect : 'current directory'}"
    end
  end
  
end
