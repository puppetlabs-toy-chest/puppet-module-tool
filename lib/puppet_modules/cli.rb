begin
  require 'thor'
rescue LoadError
  abort "Requires 'thor'"
end

class PuppetModules::CLI < Thor

  map '-V' => :version
  
  def self.method_option_repository
    method_option :repository, :default => "http://modules.puppetlabs.com", :desc => "Module repository to use"
  end

  desc "version", "Show the version information for this tool"
  def version
    PuppetModules::VERSION
  end

  desc "generate MODULE_NAME", "Generate boilerplate for a new module (eg, 'user/modname')"
  method_option_repository
  def generate(name)
    set_repository
    PuppetModules::Applications::Generator.run(name)
  end

  desc "freeze", "Freeze the module skeleton (to customize for `generate`)"
  def freeze
    PuppetModules::Applications::Freezer.run
  end

  desc "clean", "Clears module cache (all repositories)"
  def clean
    PuppetModules::Applications::Cleaner.run
  end

  desc "build [PATH_TO_MODULE]", "Build a module for release"
  def build(path = Dir.pwd)
    PuppetModules::Applications::Builder.run(path)
  end

  desc "release FILENAME", "Release a module tarball (.tar.gz)"
  method_option_repository
  def release(filename)
    set_repository
    PuppetModules::Applications::Releaser.run(filename)
  end

  desc "unrelease MODULE_NAME", "Unrelease a module (eg, 'user/modname')"
  method_option :version, :alias => :v, :required => true, :desc => "The version to unrelease"
  method_option_repository
  def unrelease(module_name)
    set_repository
    PuppetModules::Applications::Unreleaser.run(module_name,
                                                options[:version])
  end

  desc "install MODULE_NAME [OPTIONS]", "Install a module (eg, 'user/modname') from a repository"
  method_option :version, :alias => :v, :desc => "Version to install (can be a requirement, eg '>= 1.0.3', defaults to latest version)"
  method_option :force, :alias => :f, :type => :boolean, :desc => "Force overwrite of existing module, if any"
  method_option_repository
  def install(module_name)
    set_repository
    PuppetModules::Applications::Installer.run(module_name, options[:version], options[:force])
  end

  desc "search TERM", "Search the module repository for a module matching TERM"
  method_option_repository
  def search(term)
    set_repository
    PuppetModules::Applications::Searcher.run(term)
  end

  desc "register MODULE_NAME", "Register a new module (eg, 'user/modname')"
  def register(module_name)
    set_repository
    PuppetModules::Applications::Registrar.run(module_name)
  end

  no_tasks do
    def set_repository
      PuppetModules.repository = options[:repository]
    end
  end
  
end
